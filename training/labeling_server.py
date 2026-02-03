#!/usr/bin/env python3
"""
바벨 끝단 웹 라벨링 서버
- 로컬 서버로 구동
- 브라우저에서 이미지 라벨링
- YOLO 형식으로 자동 저장

사용법:
    python3 labeling_server.py [포트]

    기본 포트: 8080
    브라우저에서 http://localhost:8080 접속
"""

import http.server
import socketserver
import json
import os
import urllib.parse
from pathlib import Path
import shutil
import base64

# 설정
PORT = 8085
TRAINING_DIR = Path(__file__).parent
IMAGES_DIR = TRAINING_DIR / "labeling_images_new"
LABELS_DIR = TRAINING_DIR / "labeling_labels"

# 멀티 클래스 지원
CLASS_NAMES = {
    0: "barbell_endpoint",   # 바벨 끝단 (플레이트 측면)
    1: "barbell_collar"      # 바벨 칼라 (원판 고정 클립)
}
CLASS_NAME = "barbell_endpoint"  # 기본값 (하위 호환)

# 학습 상태 (전역)
import subprocess
import threading

training_state = {
    'running': False,
    'process': None,
    'log': '',
    'completed': False,
    'success': False,
    'model_path': None
}

# 자동 라벨링 상태
auto_label_state = {
    'running': False,
    'completed': False,
    'total': 0,
    'processed': 0,
    'labeled': 0,
    'log': ''
}

# Claude 라벨링 상태
claude_label_state = {
    'running': False,
    'completed': False,
    'total': 0,
    'processed': 0,
    'labeled': 0,
    'log': ''
}

# 라벨 메타데이터 (수동/자동 구분)
LABEL_META_FILE = LABELS_DIR / '_metadata.json'

def load_label_metadata():
    if LABEL_META_FILE.exists():
        with open(LABEL_META_FILE) as f:
            return json.load(f)
    return {}

def save_label_metadata(meta):
    LABELS_DIR.mkdir(exist_ok=True)
    with open(LABEL_META_FILE, 'w') as f:
        json.dump(meta, f, indent=2)

# HTML 템플릿
HTML_TEMPLATE = '''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>바벨 끝단 라벨링 도구</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #1a1a2e;
            color: #eee;
            min-height: 100vh;
        }

        .header {
            background: #16213e;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #0f3460;
        }

        .header h1 {
            font-size: 1.5rem;
            color: #00d9ff;
        }

        .header-info {
            display: flex;
            gap: 24px;
            align-items: center;
        }

        .stat {
            text-align: center;
        }

        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #00d9ff;
        }

        .stat-label {
            font-size: 0.75rem;
            color: #888;
        }

        .main-container {
            display: flex;
            height: calc(100vh - 80px);
        }

        .sidebar {
            width: 280px;
            background: #16213e;
            padding: 16px;
            overflow-y: auto;
            border-right: 1px solid #0f3460;
        }

        .sidebar h3 {
            margin-bottom: 12px;
            color: #00d9ff;
            font-size: 0.9rem;
        }

        .upload-area {
            border: 2px dashed #0f3460;
            border-radius: 8px;
            padding: 24px;
            text-align: center;
            margin-bottom: 16px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .upload-area:hover {
            border-color: #00d9ff;
            background: rgba(0, 217, 255, 0.05);
        }

        .upload-area.dragover {
            border-color: #00d9ff;
            background: rgba(0, 217, 255, 0.1);
        }

        .upload-icon {
            font-size: 2rem;
            margin-bottom: 8px;
        }

        .image-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .image-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px;
            background: #1a1a2e;
            border-radius: 4px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .image-item:hover {
            background: #0f3460;
        }

        .image-item.active {
            background: #0f3460;
            border-left: 3px solid #00d9ff;
        }

        .image-item.labeled {
            border-left: 3px solid #00ff88;
        }

        .image-item.auto-labeled {
            border-left: 3px solid #9b59b6;
        }

        .image-item.claude-labeled {
            border-left: 3px solid #e67e22;
        }

        .image-item.selected {
            background: #3a1c1c !important;
            border: 2px solid #ff4444 !important;
        }

        .label-badge {
            font-size: 0.6rem;
            padding: 2px 4px;
            border-radius: 3px;
            margin-left: 4px;
        }

        .label-badge.manual {
            background: #00ff88;
            color: #000;
        }

        .label-badge.auto {
            background: #9b59b6;
            color: #fff;
        }

        .label-badge.claude {
            background: #e67e22;
            color: #fff;
        }

        .image-thumb {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border-radius: 4px;
        }

        .image-name {
            flex: 1;
            font-size: 0.8rem;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .label-count {
            background: #00ff88;
            color: #000;
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 0.7rem;
            font-weight: bold;
        }

        .canvas-container {
            flex: 1;
            display: flex;
            flex-direction: column;
            padding: 16px;
        }

        .toolbar {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .btn-primary {
            background: #00d9ff;
            color: #000;
        }

        .btn-primary:hover {
            background: #00b8d9;
        }

        .btn-danger {
            background: #ff4757;
            color: #fff;
        }

        .btn-danger:hover {
            background: #ff3344;
        }

        .btn-secondary {
            background: #0f3460;
            color: #fff;
        }

        .btn-secondary:hover {
            background: #1a4a7a;
        }

        .btn-success {
            background: #00ff88;
            color: #000;
        }

        .btn-success:hover {
            background: #00dd77;
        }

        .filter-btn {
            padding: 4px 8px;
            font-size: 0.75rem;
            background: transparent;
            border: 1px solid #444;
            color: #888;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .filter-btn:hover {
            background: #333;
            color: #fff;
        }

        .filter-btn.active {
            background: #444;
            color: #fff;
            border-color: #666;
        }

        .canvas-wrapper {
            flex: 1;
            position: relative;
            background: #0d0d1a;
            border-radius: 8px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #canvas {
            max-width: 100%;
            max-height: 100%;
            cursor: crosshair;
        }

        .instructions {
            position: absolute;
            bottom: 16px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0, 0, 0, 0.8);
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 0.85rem;
            color: #aaa;
        }

        .instructions kbd {
            background: #333;
            padding: 2px 6px;
            border-radius: 3px;
            margin: 0 2px;
        }

        .label-list {
            margin-top: 16px;
            padding: 12px;
            background: #16213e;
            border-radius: 8px;
        }

        .label-list h4 {
            margin-bottom: 8px;
            color: #00d9ff;
            font-size: 0.85rem;
        }

        .label-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 8px;
            background: #1a1a2e;
            border-radius: 4px;
            margin-bottom: 4px;
            font-size: 0.8rem;
        }

        .label-item:hover {
            background: #0f3460;
        }

        .delete-label {
            color: #ff4757;
            cursor: pointer;
            padding: 2px 6px;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }

        .empty-state .icon {
            font-size: 4rem;
            margin-bottom: 16px;
        }

        .progress-bar {
            width: 100%;
            height: 4px;
            background: #0f3460;
            border-radius: 2px;
            margin-top: 8px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: #00ff88;
            transition: width 0.3s;
        }

        .navigation {
            display: flex;
            gap: 8px;
            margin-left: auto;
        }

        .shortcut-hint {
            font-size: 0.7rem;
            color: #666;
            margin-left: 4px;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .saving {
            animation: pulse 1s infinite;
        }

        /* Toast notification */
        .toast {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #00ff88;
            color: #000;
            padding: 16px 24px;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0, 255, 136, 0.3);
            z-index: 1000;
            transform: translateX(400px);
            transition: transform 0.3s ease;
            max-width: 400px;
        }

        .toast.show {
            transform: translateX(0);
        }

        .toast.error {
            background: #ff4757;
            color: #fff;
        }

        .toast h4 {
            margin-bottom: 8px;
            font-size: 1.1rem;
        }

        .toast p {
            font-size: 0.9rem;
            margin: 4px 0;
        }

        .toast code {
            background: rgba(0,0,0,0.2);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
        }

        /* Modal */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.8);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }

        .modal.show {
            display: flex;
        }

        .modal-content {
            background: #16213e;
            padding: 32px;
            border-radius: 12px;
            max-width: 500px;
            width: 90%;
        }

        .modal-content h3 {
            color: #00ff88;
            margin-bottom: 16px;
        }

        .modal-content p {
            margin: 8px 0;
            color: #ccc;
        }

        .modal-content code {
            display: block;
            background: #1a1a2e;
            padding: 12px;
            border-radius: 6px;
            margin: 12px 0;
            font-family: monospace;
            color: #00d9ff;
            overflow-x: auto;
        }

        .modal-content .btn {
            margin-top: 16px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏋️ 바벨 끝단 라벨링 도구</h1>
        <div class="header-info">
            <div class="stat">
                <div class="stat-value" id="totalImages">0</div>
                <div class="stat-label">전체 이미지</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="manualLabeled" style="color: #00ff88;">0</div>
                <div class="stat-label">수동</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="autoLabeled" style="color: #9b59b6;">0</div>
                <div class="stat-label">YOLO</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="claudeLabeled" style="color: #e67e22;">0</div>
                <div class="stat-label">Claude</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="totalLabels">0</div>
                <div class="stat-label">총 라벨 수</div>
            </div>
        </div>
    </div>

    <div class="main-container">
        <div class="sidebar">
            <h3>📁 이미지 업로드</h3>
            <div class="upload-area" id="uploadArea">
                <div class="upload-icon">📤</div>
                <div>이미지를 드래그하거나<br>클릭하여 업로드</div>
                <input type="file" id="fileInput" multiple accept="image/*" style="display: none;">
            </div>

            <div style="display: flex; gap: 8px; margin-bottom: 16px;">
                <button class="btn btn-secondary" onclick="loadCrawledImages()" style="flex: 1;">
                    📂 크롤링 이미지 불러오기
                </button>
            </div>

            <h3>🖼️ 이미지 목록</h3>
            <div style="display: flex; gap: 4px; margin-bottom: 8px; flex-wrap: wrap;">
                <button class="filter-btn active" onclick="setFilter('all')" id="filter-all">전체</button>
                <button class="filter-btn" onclick="setFilter('claude')" id="filter-claude" style="border-color: #e67e22;">🧠 Claude</button>
                <button class="filter-btn" onclick="setFilter('manual')" id="filter-manual" style="border-color: #00ff88;">✋ 수동</button>
                <button class="filter-btn" onclick="setFilter('auto')" id="filter-auto" style="border-color: #9b59b6;">🤖 YOLO</button>
                <button class="filter-btn" onclick="setFilter('unlabeled')" id="filter-unlabeled">⬜ 미라벨</button>
            </div>

            <!-- 다중 선택 컨트롤 -->
            <div id="multiSelectControls" style="display: flex; gap: 4px; margin-bottom: 8px; flex-wrap: wrap; align-items: center;">
                <label style="color: #888; font-size: 0.8rem; display: flex; align-items: center; gap: 4px;">
                    <input type="checkbox" id="multiSelectMode" onchange="toggleMultiSelect()"> 다중선택
                </label>
                <button class="filter-btn" onclick="selectAllVisible()" id="selectAllBtn" style="display: none;">전체선택</button>
                <button class="filter-btn" onclick="deselectAll()" id="deselectBtn" style="display: none;">선택해제</button>
                <button class="filter-btn" onclick="deleteSelected()" id="deleteSelectedBtn" style="display: none; background: #ff4444; border-color: #ff4444; color: white;">🗑️ 삭제 (<span id="selectedCount">0</span>)</button>
            </div>

            <div class="progress-bar">
                <div class="progress-fill" id="progressFill" style="width: 0%"></div>
            </div>
            <div class="image-list" id="imageList">
                <div class="empty-state">
                    <div>이미지를 업로드하세요</div>
                </div>
            </div>
        </div>

        <div class="canvas-container">
            <div class="toolbar">
                <button class="btn btn-primary" onclick="saveLabels()">
                    💾 저장 <span class="shortcut-hint">(S)</span>
                </button>
                <button class="btn btn-danger" onclick="clearLabels()">
                    🗑️ 전체 삭제
                </button>
                <button class="btn btn-secondary" onclick="undoLabel()">
                    ↩️ 실행취소 <span class="shortcut-hint">(Z)</span>
                </button>
                <button class="btn btn-success" onclick="exportDataset()">
                    📦 Export
                </button>
                <button class="btn btn-success" onclick="startTraining(false)" style="background: #ff6b6b;">
                    🚀 이어서 학습
                </button>
                <button class="btn btn-success" onclick="startTraining(true)" style="background: #e74c3c;">
                    🆕 새로 학습
                </button>
                <button class="btn btn-success" onclick="autoLabel()" style="background: #9b59b6;">
                    🤖 YOLO 자동
                </button>
                <button class="btn btn-success" onclick="claudeLabel()" style="background: #e67e22;">
                    🧠 Claude AI
                </button>

                <div style="display: flex; align-items: center; gap: 8px; margin-left: 20px; padding: 4px 12px; background: #2d2d2d; border-radius: 4px;">
                    <span style="color: #888; font-size: 12px;">클래스:</span>
                    <select id="classSelector" onchange="changeClass()" style="background: #3d3d3d; color: white; border: 1px solid #555; padding: 4px 8px; border-radius: 4px; font-size: 13px;">
                        <option value="0" style="color: #00ff88;">🎯 바벨 끝단 (플레이트)</option>
                        <option value="1" style="color: #ff6b6b;">🔒 바벨 칼라 (고정클립)</option>
                    </select>
                </div>

                <div class="navigation">
                    <button class="btn btn-secondary" onclick="prevImage()">
                        ◀ 이전 <span class="shortcut-hint">(A)</span>
                    </button>
                    <button class="btn btn-secondary" onclick="nextImage()">
                        다음 ▶ <span class="shortcut-hint">(D)</span>
                    </button>
                </div>
            </div>

            <div class="canvas-wrapper" id="canvasWrapper">
                <div class="empty-state" id="emptyCanvas">
                    <div class="icon">🖼️</div>
                    <div>이미지를 선택하세요</div>
                </div>
                <canvas id="canvas" style="display: none;"></canvas>
            </div>

            <div class="instructions">
                <kbd>클릭 드래그</kbd> 바운딩 박스 그리기 |
                <kbd>우클릭</kbd> 마지막 삭제 |
                <kbd>A/D</kbd> 이전/다음 |
                <kbd>S</kbd> 저장
            </div>

            <div class="label-list">
                <h4>📋 현재 라벨 (<span id="labelCount">0</span>개)</h4>
                <div id="labelItems"></div>
            </div>
        </div>
    </div>

    <!-- Toast notification -->
    <div class="toast" id="toast">
        <h4 id="toastTitle">알림</h4>
        <div id="toastContent"></div>
    </div>

    <!-- Export modal -->
    <div class="modal" id="exportModal">
        <div class="modal-content">
            <h3>✅ 데이터셋 Export 완료!</h3>
            <p><strong>위치:</strong></p>
            <code id="exportPath"></code>
            <p id="exportStats"></p>
            <button class="btn btn-primary" onclick="closeModal()">확인</button>
        </div>
    </div>

    <!-- Training modal -->
    <div class="modal" id="trainingModal">
        <div class="modal-content" style="max-width: 600px;">
            <h3 id="trainingTitle">🚀 모델 학습</h3>
            <div id="trainingStatus" style="margin: 16px 0;">
                <p>학습 준비 중...</p>
            </div>
            <div style="background: #1a1a2e; padding: 12px; border-radius: 6px; max-height: 300px; overflow-y: auto; font-family: monospace; font-size: 0.85rem;">
                <pre id="trainingLog" style="margin: 0; white-space: pre-wrap; color: #00d9ff;"></pre>
            </div>
            <div style="margin-top: 16px; display: flex; gap: 8px;">
                <button class="btn btn-danger" id="stopTrainingBtn" onclick="stopTraining()">⏹ 학습 중지</button>
                <button class="btn btn-primary" id="closeTrainingBtn" onclick="closeTrainingModal()" style="display: none;">확인</button>
            </div>
        </div>
    </div>

    <script>
        // State
        let images = [];
        let currentIndex = -1;
        let currentLabels = [];
        let isDrawing = false;
        let startX, startY;
        let canvas, ctx;
        let currentImage = null;
        let scale = 1;
        let offsetX = 0, offsetY = 0;
        let currentFilter = 'all';
        let currentClass = 0;  // 0: 바벨 끝단, 1: 바벨 전체

        const CLASS_COLORS = {
            0: '#00ff88',  // 바벨 끝단 - 녹색
            1: '#ff6b6b'   // 바벨 칼라 - 빨강
        };

        const CLASS_NAMES = {
            0: '바벨 끝단',
            1: '바벨 칼라'
        };

        function changeClass() {
            currentClass = parseInt(document.getElementById('classSelector').value);
            redraw();  // 현재 그리기 색상 반영
        }

        function setFilter(filter) {
            currentFilter = filter;
            // Update button states
            document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
            document.getElementById('filter-' + filter).classList.add('active');
            renderImageList();
        }

        function getFilteredImages() {
            if (currentFilter === 'all') return images;
            return images.filter(img => {
                if (currentFilter === 'claude') return img.labelType === 'claude';
                if (currentFilter === 'manual') return img.labelType === 'manual' || (img.labelCount > 0 && !img.labelType);
                if (currentFilter === 'auto') return img.labelType === 'auto';
                if (currentFilter === 'unlabeled') return img.labelCount === 0;
                return true;
            });
        }

        // 다중 선택 상태
        let multiSelectMode = false;
        let selectedImages = new Set();

        function toggleMultiSelect() {
            multiSelectMode = document.getElementById('multiSelectMode').checked;
            document.getElementById('selectAllBtn').style.display = multiSelectMode ? 'inline-block' : 'none';
            document.getElementById('deselectBtn').style.display = multiSelectMode ? 'inline-block' : 'none';
            document.getElementById('deleteSelectedBtn').style.display = multiSelectMode ? 'inline-block' : 'none';
            if (!multiSelectMode) {
                selectedImages.clear();
            }
            renderImageList();
        }

        async function toggleImageSelection(imageName, realIndex, event) {
            if (event) event.stopPropagation();

            // 선택 상태 토글
            if (selectedImages.has(imageName)) {
                selectedImages.delete(imageName);
            } else {
                selectedImages.add(imageName);
            }
            updateSelectedCount();

            // 이미지 미리보기 표시 (메인 캔버스에 로드)
            await selectImage(realIndex);
        }

        function selectAllVisible() {
            const filtered = getFilteredImages();
            filtered.forEach(img => selectedImages.add(img.name));
            updateSelectedCount();
            renderImageList();
        }

        function deselectAll() {
            selectedImages.clear();
            updateSelectedCount();
            renderImageList();
        }

        function updateSelectedCount() {
            document.getElementById('selectedCount').textContent = selectedImages.size;
        }

        async function deleteSelected() {
            if (selectedImages.size === 0) {
                alert('선택된 이미지가 없습니다.');
                return;
            }

            if (!confirm(`${selectedImages.size}개의 라벨을 삭제하시겠습니까?`)) {
                return;
            }

            try {
                const response = await fetch('/api/delete-labels', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ images: Array.from(selectedImages) })
                });

                const result = await response.json();
                if (result.success) {
                    alert(`${result.deleted}개 라벨 삭제됨`);
                    selectedImages.clear();
                    updateSelectedCount();
                    loadImageList();
                } else {
                    alert('삭제 실패: ' + result.error);
                }
            } catch (e) {
                alert('삭제 중 오류: ' + e.message);
            }
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', () => {
            canvas = document.getElementById('canvas');
            ctx = canvas.getContext('2d');

            setupEventListeners();
            loadImageList();
        });

        function setupEventListeners() {
            // Upload area
            const uploadArea = document.getElementById('uploadArea');
            const fileInput = document.getElementById('fileInput');

            uploadArea.onclick = () => fileInput.click();

            uploadArea.ondragover = (e) => {
                e.preventDefault();
                uploadArea.classList.add('dragover');
            };

            uploadArea.ondragleave = () => {
                uploadArea.classList.remove('dragover');
            };

            uploadArea.ondrop = (e) => {
                e.preventDefault();
                uploadArea.classList.remove('dragover');
                handleFiles(e.dataTransfer.files);
            };

            fileInput.onchange = (e) => handleFiles(e.target.files);

            // Canvas events
            canvas.onmousedown = startDrawing;
            canvas.onmousemove = draw;
            canvas.onmouseup = endDrawing;
            canvas.onmouseleave = endDrawing;
            canvas.oncontextmenu = (e) => {
                e.preventDefault();
                undoLabel();
            };

            // Keyboard shortcuts
            document.onkeydown = (e) => {
                if (e.key === 'a' || e.key === 'A' || e.key === 'ArrowLeft') {
                    prevImage();
                } else if (e.key === 'd' || e.key === 'D' || e.key === 'ArrowRight') {
                    nextImage();
                } else if (e.key === 's' || e.key === 'S') {
                    e.preventDefault();
                    saveLabels();
                } else if (e.key === 'z' || e.key === 'Z') {
                    undoLabel();
                }
            };
        }

        async function handleFiles(files) {
            const formData = new FormData();
            for (const file of files) {
                if (file.type.startsWith('image/')) {
                    formData.append('images', file);
                }
            }

            const response = await fetch('/api/upload', {
                method: 'POST',
                body: formData
            });

            if (response.ok) {
                loadImageList();
            }
        }

        async function loadCrawledImages() {
            showToast('불러오는 중...', '크롤링 이미지를 불러오고 있습니다...');
            const response = await fetch('/api/load-crawled', { method: 'POST' });
            if (response.ok) {
                const result = await response.json();
                showToast('불러오기 완료', `${result.count}개의 이미지를 불러왔습니다.`);
                loadImageList();
            }
        }

        async function loadImageList() {
            const response = await fetch('/api/images');
            const data = await response.json();
            images = data.images;

            updateStats(data);
            renderImageList();

            if (images.length > 0 && currentIndex === -1) {
                selectImage(0);
            }
        }

        function updateStats(data) {
            document.getElementById('totalImages').textContent = data.total;
            document.getElementById('manualLabeled').textContent = data.manualLabeled || 0;
            document.getElementById('autoLabeled').textContent = data.autoLabeled || 0;
            document.getElementById('claudeLabeled').textContent = data.claudeLabeled || 0;
            document.getElementById('totalLabels').textContent = data.totalLabels;

            const progress = data.total > 0 ? (data.labeled / data.total * 100) : 0;
            document.getElementById('progressFill').style.width = progress + '%';
        }

        function renderImageList() {
            const container = document.getElementById('imageList');
            const filtered = getFilteredImages();

            if (filtered.length === 0) {
                container.innerHTML = '<div class="empty-state"><div>해당 필터에 맞는 이미지가 없습니다</div></div>';
                return;
            }

            container.innerHTML = filtered.map((img, i) => {
                const realIndex = images.indexOf(img);
                let labelClass = '';
                let badge = '';

                if (img.labelCount > 0) {
                    if (img.labelType === 'auto') {
                        labelClass = 'auto-labeled';
                        badge = `<span class="label-badge auto">YOLO</span>`;
                    } else if (img.labelType === 'claude') {
                        labelClass = 'claude-labeled';
                        badge = `<span class="label-badge claude">Claude</span>`;
                    } else {
                        labelClass = 'labeled';
                        badge = `<span class="label-badge manual">수동</span>`;
                    }
                }

                const isSelected = selectedImages.has(img.name);
                const checkbox = multiSelectMode ?
                    `<input type="checkbox" class="multi-checkbox" ${isSelected ? 'checked' : ''}
                     onclick="toggleImageSelection('${img.name}', ${realIndex}, event)"
                     style="position: absolute; top: 4px; left: 4px; width: 18px; height: 18px; z-index: 10;">` : '';

                return `
                <div class="image-item ${realIndex === currentIndex ? 'active' : ''} ${labelClass} ${isSelected ? 'selected' : ''}"
                     onclick="${multiSelectMode ? `toggleImageSelection('${img.name}', ${realIndex}, event)` : `selectImage(${realIndex})`}"
                     style="position: relative;">
                    ${checkbox}
                    <img class="image-thumb" src="/images/${img.name}" alt="">
                    <span class="image-name">${img.name}</span>
                    ${img.labelCount > 0 ? `<span class="label-count">${img.labelCount}</span>${badge}` : ''}
                </div>
            `}).join('');

            // Update filter counts
            const counts = {
                all: images.length,
                claude: images.filter(i => i.labelType === 'claude').length,
                manual: images.filter(i => i.labelType === 'manual' || (i.labelCount > 0 && !i.labelType)).length,
                auto: images.filter(i => i.labelType === 'auto').length,
                unlabeled: images.filter(i => i.labelCount === 0).length
            };
            document.getElementById('filter-all').textContent = `전체 (${counts.all})`;
            document.getElementById('filter-claude').textContent = `🧠 Claude (${counts.claude})`;
            document.getElementById('filter-manual').textContent = `✋ 수동 (${counts.manual})`;
            document.getElementById('filter-auto').textContent = `🤖 YOLO (${counts.auto})`;
            document.getElementById('filter-unlabeled').textContent = `⬜ 미라벨 (${counts.unlabeled})`;
        }

        async function selectImage(index) {
            // 이미지 전환 시 자동 저장 안함 - 사용자가 명시적으로 저장 버튼 눌러야 함
            currentIndex = index;
            const img = images[index];

            // Load image
            currentImage = new Image();
            currentImage.onload = () => {
                setupCanvas();
                loadLabels(img.name);
            };
            currentImage.src = `/images/${img.name}`;

            document.getElementById('emptyCanvas').style.display = 'none';
            canvas.style.display = 'block';

            renderImageList();
        }

        function setupCanvas() {
            const wrapper = document.getElementById('canvasWrapper');
            const maxW = wrapper.clientWidth - 32;
            const maxH = wrapper.clientHeight - 32;

            const imgW = currentImage.width;
            const imgH = currentImage.height;

            scale = Math.min(maxW / imgW, maxH / imgH, 1);

            canvas.width = imgW * scale;
            canvas.height = imgH * scale;

            redraw();
        }

        async function loadLabels(imageName) {
            const response = await fetch(`/api/labels/${imageName}`);
            const data = await response.json();
            currentLabels = data.labels || [];
            updateLabelUI();
            redraw();
        }

        function redraw() {
            if (!currentImage) return;

            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.drawImage(currentImage, 0, 0, canvas.width, canvas.height);

            // Draw labels
            currentLabels.forEach((label, i) => {
                const x = (label.cx - label.w / 2) * canvas.width;
                const y = (label.cy - label.h / 2) * canvas.height;
                const w = label.w * canvas.width;
                const h = label.h * canvas.height;

                // 클래스별 색상
                const classId = label.classId || 0;
                const color = CLASS_COLORS[classId] || '#00ff88';
                const className = CLASS_NAMES[classId] || '알 수 없음';

                // Box
                ctx.strokeStyle = color;
                ctx.lineWidth = 2;
                ctx.strokeRect(x, y, w, h);

                // Center point
                const cx = label.cx * canvas.width;
                const cy = label.cy * canvas.height;

                ctx.fillStyle = '#ff0000';
                ctx.beginPath();
                ctx.arc(cx, cy, 5, 0, Math.PI * 2);
                ctx.fill();

                // Crosshair
                ctx.strokeStyle = '#ff0000';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(cx - 15, cy);
                ctx.lineTo(cx + 15, cy);
                ctx.moveTo(cx, cy - 15);
                ctx.lineTo(cx, cy + 15);
                ctx.stroke();

                // Label number + class name
                ctx.fillStyle = color;
                ctx.font = 'bold 14px sans-serif';
                ctx.fillText(`#${i + 1} ${className}`, x + 4, y - 4);
            });
        }

        function startDrawing(e) {
            if (e.button !== 0) return; // Left click only

            const rect = canvas.getBoundingClientRect();
            startX = e.clientX - rect.left;
            startY = e.clientY - rect.top;
            isDrawing = true;
        }

        function draw(e) {
            if (!isDrawing) return;

            const rect = canvas.getBoundingClientRect();
            const currentX = e.clientX - rect.left;
            const currentY = e.clientY - rect.top;

            redraw();

            // Draw current box
            ctx.strokeStyle = '#00d9ff';
            ctx.lineWidth = 2;
            ctx.setLineDash([5, 5]);
            ctx.strokeRect(startX, startY, currentX - startX, currentY - startY);
            ctx.setLineDash([]);
        }

        function endDrawing(e) {
            if (!isDrawing) return;
            isDrawing = false;

            const rect = canvas.getBoundingClientRect();
            const endX = e.clientX - rect.left;
            const endY = e.clientY - rect.top;

            // Calculate normalized coordinates
            let x1 = Math.min(startX, endX) / canvas.width;
            let y1 = Math.min(startY, endY) / canvas.height;
            let x2 = Math.max(startX, endX) / canvas.width;
            let y2 = Math.max(startY, endY) / canvas.height;

            // If too small, create default size box
            if (Math.abs(x2 - x1) < 0.02 && Math.abs(y2 - y1) < 0.02) {
                const size = 0.05; // 5% of image
                x1 = Math.max(0, (startX / canvas.width) - size / 2);
                y1 = Math.max(0, (startY / canvas.height) - size / 2);
                x2 = Math.min(1, (startX / canvas.width) + size / 2);
                y2 = Math.min(1, (startY / canvas.height) + size / 2);
            }

            const label = {
                classId: currentClass,
                cx: (x1 + x2) / 2,
                cy: (y1 + y2) / 2,
                w: x2 - x1,
                h: y2 - y1
            };

            currentLabels.push(label);
            updateLabelUI();
            redraw();
        }

        function undoLabel() {
            if (currentLabels.length > 0) {
                currentLabels.pop();
                updateLabelUI();
                redraw();
            }
        }

        function clearLabels() {
            if (confirm('현재 이미지의 라벨을 모두 삭제하시겠습니까?')) {
                currentLabels = [];
                updateLabelUI();
                redraw();
                saveLabels(false, false);  // 서버에도 저장 (빈 라벨, 다음으로 안넘어감)
                showToast('삭제 완료', '현재 이미지의 라벨이 삭제되었습니다.');
            }
        }

        function deleteLabel(index) {
            currentLabels.splice(index, 1);
            updateLabelUI();
            redraw();
        }

        function updateLabelUI() {
            document.getElementById('labelCount').textContent = currentLabels.length;

            const container = document.getElementById('labelItems');
            if (currentLabels.length === 0) {
                container.innerHTML = '<div style="color: #666; font-size: 0.8rem;">라벨이 없습니다</div>';
                return;
            }

            container.innerHTML = currentLabels.map((label, i) => {
                const classId = label.classId || 0;
                const color = CLASS_COLORS[classId] || '#00ff88';
                const className = CLASS_NAMES[classId] || '알 수 없음';
                return `
                <div class="label-item">
                    <span style="color: ${color};">#${i + 1} [${className}]</span>
                    <span class="delete-label" onclick="deleteLabel(${i})">✕</span>
                </div>
            `}).join('');
        }

        async function saveLabels(showAlert = true, autoNext = true) {
            if (currentIndex < 0) return;

            const imageName = images[currentIndex].name;
            const savedIndex = currentIndex;

            const response = await fetch(`/api/labels/${imageName}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ labels: currentLabels })
            });

            if (response.ok) {
                if (showAlert) {
                    // Quick visual feedback
                    const btn = document.querySelector('.btn-primary');
                    btn.classList.add('saving');
                    setTimeout(() => btn.classList.remove('saving'), 500);
                }
                await loadImageList();

                // 저장 후 다음 이미지로 자동 이동
                if (autoNext && savedIndex < images.length - 1) {
                    await selectImage(savedIndex + 1);
                }
            }
        }

        function prevImage() {
            if (currentIndex > 0) {
                selectImage(currentIndex - 1);
            }
        }

        function nextImage() {
            if (currentIndex < images.length - 1) {
                selectImage(currentIndex + 1);
            }
        }

        async function exportDataset() {
            // Show loading toast
            showToast('Export 중...', '데이터셋을 생성하고 있습니다...', false);

            try {
                const response = await fetch('/api/export', { method: 'POST' });
                const result = await response.json();

                if (result.success) {
                    // Hide toast
                    hideToast();

                    // Show modal with details
                    document.getElementById('exportPath').textContent = result.path;
                    document.getElementById('exportStats').innerHTML =
                        `<strong>이미지:</strong> ${result.imageCount}개 | <strong>라벨:</strong> ${result.labelCount}개`;
                    document.getElementById('exportModal').classList.add('show');
                } else {
                    showToast('Export 실패', '오류가 발생했습니다.', true);
                }
            } catch (e) {
                showToast('Export 실패', e.message, true);
            }
        }

        function showToast(title, content, isError = false) {
            const toast = document.getElementById('toast');
            document.getElementById('toastTitle').textContent = title;
            document.getElementById('toastContent').innerHTML = content;
            toast.classList.toggle('error', isError);
            toast.classList.add('show');

            if (!isError) {
                // Auto hide after 3 seconds for non-error
                setTimeout(hideToast, 3000);
            }
        }

        function hideToast() {
            document.getElementById('toast').classList.remove('show');
        }

        function closeModal() {
            document.getElementById('exportModal').classList.remove('show');
        }

        let trainingInterval = null;

        async function startTraining(freshStart = false) {
            const mode = freshStart ? '새로 학습' : '이어서 학습';
            if (!confirm(`${mode}을 시작하시겠습니까?\\n\\n` +
                (freshStart ? '⚠️ 기본 모델(yolov8n.pt)에서 처음부터 학습합니다.' : '✅ 기존 학습 모델에서 이어서 학습합니다.'))) {
                return;
            }

            // First export the dataset
            showToast('준비 중...', '데이터셋 Export 후 학습을 시작합니다...');

            try {
                const exportRes = await fetch('/api/export', { method: 'POST' });
                const exportResult = await exportRes.json();

                if (!exportResult.success || exportResult.imageCount === 0) {
                    showToast('오류', '라벨링된 이미지가 없습니다. 먼저 라벨링을 해주세요.', true);
                    return;
                }

                hideToast();

                // Show training modal
                document.getElementById('trainingModal').classList.add('show');
                document.getElementById('trainingTitle').textContent = freshStart ? '🆕 새로 학습 중...' : '🚀 이어서 학습 중...';
                document.getElementById('trainingLog').textContent = `데이터셋: ${exportResult.imageCount}개 이미지, ${exportResult.labelCount}개 라벨\\n모드: ${mode}\\n\\n학습 시작 중...\\n`;
                document.getElementById('stopTrainingBtn').style.display = 'inline-block';
                document.getElementById('closeTrainingBtn').style.display = 'none';

                // Start training with fresh parameter
                const trainRes = await fetch('/api/train', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ fresh: freshStart })
                });
                const trainResult = await trainRes.json();

                if (trainResult.success) {
                    // Poll for training status
                    trainingInterval = setInterval(checkTrainingStatus, 2000);
                } else {
                    document.getElementById('trainingLog').textContent += `\\n오류: ${trainResult.error}`;
                    document.getElementById('stopTrainingBtn').style.display = 'none';
                    document.getElementById('closeTrainingBtn').style.display = 'inline-block';
                }
            } catch (e) {
                showToast('오류', e.message, true);
            }
        }

        async function checkTrainingStatus() {
            try {
                const res = await fetch('/api/train/status');
                const status = await res.json();

                document.getElementById('trainingLog').textContent = status.log || '학습 중...';

                // Auto-scroll to bottom
                const logDiv = document.getElementById('trainingLog').parentElement;
                logDiv.scrollTop = logDiv.scrollHeight;

                if (status.completed) {
                    clearInterval(trainingInterval);
                    trainingInterval = null;

                    if (status.success) {
                        document.getElementById('trainingTitle').textContent = '✅ 학습 완료!';
                        document.getElementById('trainingStatus').innerHTML =
                            `<p style="color: #00ff88;"><strong>모델 저장 위치:</strong> ${status.modelPath || 'runs/detect/train/weights/best.pt'}</p>`;
                    } else {
                        document.getElementById('trainingTitle').textContent = '❌ 학습 실패';
                    }

                    document.getElementById('stopTrainingBtn').style.display = 'none';
                    document.getElementById('closeTrainingBtn').style.display = 'inline-block';
                }
            } catch (e) {
                console.error('Status check failed:', e);
            }
        }

        async function stopTraining() {
            if (trainingInterval) {
                clearInterval(trainingInterval);
                trainingInterval = null;
            }

            await fetch('/api/train/stop', { method: 'POST' });

            document.getElementById('trainingTitle').textContent = '⏹ 학습 중지됨';
            document.getElementById('stopTrainingBtn').style.display = 'none';
            document.getElementById('closeTrainingBtn').style.display = 'inline-block';
        }

        function closeTrainingModal() {
            document.getElementById('trainingModal').classList.remove('show');
            if (trainingInterval) {
                clearInterval(trainingInterval);
                trainingInterval = null;
            }
        }

        // Auto-labeling
        let autoLabelInterval = null;

        async function autoLabel() {
            const unlabeledCount = images.filter(img => img.labelCount === 0).length;

            if (unlabeledCount === 0) {
                showToast('알림', '라벨링되지 않은 이미지가 없습니다.', false);
                return;
            }

            if (!confirm(`${unlabeledCount}개의 이미지를 자동 라벨링하시겠습니까?\\n\\n학습된 모델을 사용하여 바벨 끝단을 자동으로 감지합니다.`)) {
                return;
            }

            // Show training modal for progress
            document.getElementById('trainingModal').classList.add('show');
            document.getElementById('trainingTitle').textContent = '🤖 자동 라벨링 중...';
            document.getElementById('trainingStatus').innerHTML = `<p>총 ${unlabeledCount}개 이미지 처리 중...</p>`;
            document.getElementById('trainingLog').textContent = '자동 라벨링 시작...\\n';
            document.getElementById('stopTrainingBtn').style.display = 'inline-block';
            document.getElementById('closeTrainingBtn').style.display = 'none';

            try {
                const response = await fetch('/api/auto-label', { method: 'POST' });
                const result = await response.json();

                if (result.success) {
                    // Poll for status
                    autoLabelInterval = setInterval(checkAutoLabelStatus, 1000);
                } else {
                    document.getElementById('trainingLog').textContent += `\\n오류: ${result.error}`;
                    document.getElementById('stopTrainingBtn').style.display = 'none';
                    document.getElementById('closeTrainingBtn').style.display = 'inline-block';
                }
            } catch (e) {
                showToast('오류', e.message, true);
                closeTrainingModal();
            }
        }

        async function checkAutoLabelStatus() {
            try {
                const res = await fetch('/api/auto-label/status');
                const status = await res.json();

                document.getElementById('trainingLog').textContent = status.log || '처리 중...';
                document.getElementById('trainingStatus').innerHTML =
                    `<p>진행: ${status.processed}/${status.total} (${status.labeled}개 라벨 생성)</p>`;

                // Auto-scroll
                const logDiv = document.getElementById('trainingLog').parentElement;
                logDiv.scrollTop = logDiv.scrollHeight;

                if (status.completed) {
                    clearInterval(autoLabelInterval);
                    autoLabelInterval = null;

                    document.getElementById('trainingTitle').textContent = '✅ 자동 라벨링 완료!';
                    document.getElementById('trainingStatus').innerHTML =
                        `<p style="color: #00ff88;"><strong>${status.labeled}개</strong> 라벨이 생성되었습니다.</p>
                         <p style="color: #ffaa00;">⚠️ 자동 생성된 라벨을 검토하세요!</p>`;

                    document.getElementById('stopTrainingBtn').style.display = 'none';
                    document.getElementById('closeTrainingBtn').style.display = 'inline-block';

                    // Refresh image list
                    loadImageList();
                }
            } catch (e) {
                console.error('Status check failed:', e);
            }
        }

        // Claude AI Labeling
        let claudeLabelInterval = null;

        async function claudeLabel() {
            // Check for API key first
            let apiKey = localStorage.getItem('anthropic_api_key');

            if (!apiKey) {
                apiKey = prompt('Anthropic API 키를 입력하세요:\\n(https://console.anthropic.com 에서 발급)');
                if (!apiKey) return;
                localStorage.setItem('anthropic_api_key', apiKey);
            }

            // Options: current image or all unlabeled
            const choice = confirm('현재 이미지만 라벨링할까요?\\n\\n확인 = 현재 이미지만\\n취소 = 라벨 없는 이미지 전체');

            if (choice && currentIndex < 0) {
                showToast('오류', '먼저 이미지를 선택하세요.', true);
                return;
            }

            // Show modal
            document.getElementById('trainingModal').classList.add('show');
            document.getElementById('trainingTitle').textContent = '🧠 Claude AI 라벨링 중...';
            document.getElementById('trainingStatus').innerHTML = '<p>Claude가 이미지를 분석하고 있습니다...</p>';
            document.getElementById('trainingLog').textContent = 'Claude API 연결 중...\\n';
            document.getElementById('stopTrainingBtn').style.display = 'inline-block';
            document.getElementById('closeTrainingBtn').style.display = 'none';

            try {
                const endpoint = choice ? '/api/claude-label/single' : '/api/claude-label/batch';
                const body = choice
                    ? { imageName: images[currentIndex].name, apiKey }
                    : { apiKey };

                const response = await fetch(endpoint, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(body)
                });

                const result = await response.json();

                if (result.success) {
                    if (choice) {
                        // Single image - show result immediately
                        document.getElementById('trainingLog').textContent = result.log || 'Claude 분석 완료';
                        document.getElementById('trainingTitle').textContent = '✅ Claude 라벨링 완료!';
                        document.getElementById('trainingStatus').innerHTML =
                            `<p style="color: #00ff88;">${result.labelCount || 0}개 라벨 생성</p>`;
                        document.getElementById('stopTrainingBtn').style.display = 'none';
                        document.getElementById('closeTrainingBtn').style.display = 'inline-block';

                        // Reload current image labels
                        loadLabels(images[currentIndex].name);
                        loadImageList();
                    } else {
                        // Batch - poll for status
                        claudeLabelInterval = setInterval(checkClaudeLabelStatus, 2000);
                    }
                } else {
                    document.getElementById('trainingLog').textContent = `오류: ${result.error}`;
                    if (result.error.includes('API')) {
                        localStorage.removeItem('anthropic_api_key');
                    }
                    document.getElementById('stopTrainingBtn').style.display = 'none';
                    document.getElementById('closeTrainingBtn').style.display = 'inline-block';
                }
            } catch (e) {
                document.getElementById('trainingLog').textContent = `오류: ${e.message}`;
                document.getElementById('stopTrainingBtn').style.display = 'none';
                document.getElementById('closeTrainingBtn').style.display = 'inline-block';
            }
        }

        async function checkClaudeLabelStatus() {
            try {
                const res = await fetch('/api/claude-label/status');
                const status = await res.json();

                document.getElementById('trainingLog').textContent = status.log || '처리 중...';
                document.getElementById('trainingStatus').innerHTML =
                    `<p>진행: ${status.processed}/${status.total} (${status.labeled}개 라벨 생성)</p>`;

                const logDiv = document.getElementById('trainingLog').parentElement;
                logDiv.scrollTop = logDiv.scrollHeight;

                if (status.completed) {
                    clearInterval(claudeLabelInterval);
                    claudeLabelInterval = null;

                    document.getElementById('trainingTitle').textContent = '✅ Claude 라벨링 완료!';
                    document.getElementById('trainingStatus').innerHTML =
                        `<p style="color: #00ff88;"><strong>${status.labeled}개</strong> 라벨이 생성되었습니다.</p>
                         <p style="color: #e67e22;">Claude AI가 분석한 라벨입니다.</p>`;

                    document.getElementById('stopTrainingBtn').style.display = 'none';
                    document.getElementById('closeTrainingBtn').style.display = 'inline-block';

                    loadImageList();
                }
            } catch (e) {
                console.error('Status check failed:', e);
            }
        }
    </script>
</body>
</html>
'''


class LabelingHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(TRAINING_DIR), **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == '/' or path == '/index.html':
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(HTML_TEMPLATE.encode('utf-8'))

        elif path == '/api/images':
            self.send_json(self.get_image_list())

        elif path.startswith('/api/labels/'):
            image_name = path.split('/')[-1]
            self.send_json(self.get_labels(image_name))

        elif path.startswith('/images/'):
            image_name = path.split('/')[-1]
            self.serve_image(image_name)

        elif path == '/api/train/status':
            self.send_json(self.get_training_status())

        elif path == '/api/auto-label/status':
            self.send_json(self.get_auto_label_status())

        elif path == '/api/claude-label/status':
            self.send_json(self.get_claude_label_status())

        else:
            super().do_GET()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == '/api/upload':
            self.handle_upload()

        elif path == '/api/load-crawled':
            self.handle_load_crawled()

        elif path.startswith('/api/labels/'):
            image_name = path.split('/')[-1]
            self.handle_save_labels(image_name)

        elif path == '/api/export':
            self.handle_export()

        elif path == '/api/train':
            self.handle_start_training()

        elif path == '/api/train/stop':
            self.handle_stop_training()

        elif path == '/api/auto-label':
            self.handle_start_auto_label()

        elif path == '/api/auto-label/stop':
            self.handle_stop_auto_label()

        elif path == '/api/claude-label/single':
            self.handle_claude_label_single()

        elif path == '/api/claude-label/batch':
            self.handle_claude_label_batch()

        elif path == '/api/claude-label/stop':
            self.handle_stop_claude_label()

        elif path == '/api/delete-labels':
            self.handle_delete_labels()

        else:
            self.send_error(404)

    def send_json(self, data):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

    def get_image_list(self):
        IMAGES_DIR.mkdir(exist_ok=True)
        LABELS_DIR.mkdir(exist_ok=True)

        images = []
        total_labels = 0
        labeled_count = 0
        manual_count = 0
        auto_count = 0
        claude_count = 0

        # Load metadata
        meta = load_label_metadata()

        for f in sorted(IMAGES_DIR.glob('*')):
            if f.suffix.lower() in ['.jpg', '.jpeg', '.png', '.bmp', '.webp']:
                label_path = LABELS_DIR / f'{f.stem}.txt'
                label_count = 0
                label_type = None  # 'manual', 'auto', or None

                if label_path.exists():
                    with open(label_path) as lf:
                        label_count = len([l for l in lf.readlines() if l.strip()])

                    if label_count > 0:
                        meta_val = meta.get(f.stem, 'manual')
                        # Handle both string and dict formats
                        if isinstance(meta_val, dict):
                            label_type = meta_val.get('type', 'manual')
                        else:
                            label_type = meta_val

                images.append({
                    'name': f.name,
                    'labelCount': label_count,
                    'labelType': label_type
                })

                total_labels += label_count
                if label_count > 0:
                    labeled_count += 1
                    if label_type == 'auto':
                        auto_count += 1
                    elif label_type == 'claude':
                        claude_count += 1
                    else:
                        manual_count += 1

        return {
            'images': images,
            'total': len(images),
            'labeled': labeled_count,
            'manualLabeled': manual_count,
            'autoLabeled': auto_count,
            'claudeLabeled': claude_count,
            'totalLabels': total_labels
        }

    def get_labels(self, image_name):
        stem = Path(image_name).stem
        label_path = LABELS_DIR / f'{stem}.txt'

        labels = []
        if label_path.exists():
            with open(label_path) as f:
                for line in f:
                    parts = line.strip().split()
                    if len(parts) >= 5:
                        class_id, cx, cy, w, h = parts[:5]
                        labels.append({
                            'classId': int(class_id),
                            'cx': float(cx),
                            'cy': float(cy),
                            'w': float(w),
                            'h': float(h)
                        })

        return {'labels': labels}

    def serve_image(self, image_name):
        image_path = IMAGES_DIR / image_name

        if not image_path.exists():
            self.send_error(404)
            return

        content_type = 'image/jpeg'
        if image_path.suffix.lower() == '.png':
            content_type = 'image/png'

        self.send_response(200)
        self.send_header('Content-type', content_type)
        self.end_headers()
        self.wfile.write(image_path.read_bytes())

    def handle_upload(self):
        content_type = self.headers.get('Content-Type', '')

        if 'multipart/form-data' not in content_type:
            self.send_error(400)
            return

        # Parse multipart form data
        boundary = content_type.split('boundary=')[1].encode()
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        IMAGES_DIR.mkdir(exist_ok=True)

        # Simple multipart parser
        parts = body.split(b'--' + boundary)
        count = 0

        for part in parts:
            if b'filename="' in part:
                # Extract filename
                header_end = part.find(b'\r\n\r\n')
                if header_end == -1:
                    continue

                header = part[:header_end].decode('utf-8', errors='ignore')
                filename_start = header.find('filename="') + 10
                filename_end = header.find('"', filename_start)
                filename = header[filename_start:filename_end]

                if not filename:
                    continue

                # Extract file data
                file_data = part[header_end + 4:]
                if file_data.endswith(b'\r\n'):
                    file_data = file_data[:-2]

                # Save file
                save_path = IMAGES_DIR / filename
                save_path.write_bytes(file_data)
                count += 1

        self.send_json({'success': True, 'count': count})

    def handle_load_crawled(self):
        # Load images from crawled_data/frames
        crawled_dir = TRAINING_DIR / 'crawled_data' / 'frames'
        extracted_dir = TRAINING_DIR / 'extracted_frames'

        IMAGES_DIR.mkdir(exist_ok=True)
        count = 0

        for src_dir in [crawled_dir, extracted_dir]:
            if src_dir.exists():
                for f in src_dir.glob('*'):
                    if f.suffix.lower() in ['.jpg', '.jpeg', '.png']:
                        dst = IMAGES_DIR / f.name
                        if not dst.exists():
                            shutil.copy(f, dst)
                            count += 1

        self.send_json({'success': True, 'count': count})

    def handle_save_labels(self, image_name):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        data = json.loads(body)

        LABELS_DIR.mkdir(exist_ok=True)

        stem = Path(image_name).stem
        label_path = LABELS_DIR / f'{stem}.txt'

        with open(label_path, 'w') as f:
            for label in data.get('labels', []):
                class_id = label.get('classId', 0)  # 기본값: 0 (바벨 끝단)
                cx = label['cx']
                cy = label['cy']
                w = label['w']
                h = label['h']
                f.write(f'{class_id} {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n')

        # Mark as manual label
        meta = load_label_metadata()
        meta[stem] = 'manual'
        save_label_metadata(meta)

        self.send_json({'success': True})

    def handle_export(self):
        # Create dataset directory
        dataset_dir = TRAINING_DIR / 'barbell_plate_dataset_new'
        train_images = dataset_dir / 'train' / 'images'
        train_labels = dataset_dir / 'train' / 'labels'
        valid_images = dataset_dir / 'valid' / 'images'
        valid_labels = dataset_dir / 'valid' / 'labels'

        # Clear and recreate directories
        if dataset_dir.exists():
            shutil.rmtree(dataset_dir)

        for d in [train_images, train_labels, valid_images, valid_labels]:
            d.mkdir(parents=True, exist_ok=True)

        # Get labeled images
        labeled_images = []
        for f in IMAGES_DIR.glob('*'):
            if f.suffix.lower() in ['.jpg', '.jpeg', '.png']:
                label_path = LABELS_DIR / f'{f.stem}.txt'
                if label_path.exists():
                    with open(label_path) as lf:
                        if any(l.strip() for l in lf.readlines()):
                            labeled_images.append(f)

        # Split 80/20
        import random
        random.shuffle(labeled_images)
        split_idx = int(len(labeled_images) * 0.8)
        train_set = labeled_images[:split_idx]
        valid_set = labeled_images[split_idx:]

        image_count = 0
        label_count = 0

        # Copy files
        for img in train_set:
            shutil.copy(img, train_images / img.name)
            label_src = LABELS_DIR / f'{img.stem}.txt'
            shutil.copy(label_src, train_labels / f'{img.stem}.txt')
            image_count += 1
            with open(label_src) as f:
                label_count += len([l for l in f.readlines() if l.strip()])

        for img in valid_set:
            shutil.copy(img, valid_images / img.name)
            label_src = LABELS_DIR / f'{img.stem}.txt'
            shutil.copy(label_src, valid_labels / f'{img.stem}.txt')
            image_count += 1
            with open(label_src) as f:
                label_count += len([l for l in f.readlines() if l.strip()])

        # Create data.yaml
        yaml_content = f"""# Barbell Dataset (Multi-class)
# Generated by labeling_server.py
# Total images: {image_count} (train: {len(train_set)}, valid: {len(valid_set)})
# Total labels: {label_count}

path: {dataset_dir.absolute()}
train: train/images
val: valid/images

names:
  0: barbell_endpoint
  1: barbell

nc: 2
"""
        (dataset_dir / 'data.yaml').write_text(yaml_content)

        print(f"Dataset exported: {image_count} images, {label_count} labels")

        self.send_json({
            'success': True,
            'path': str(dataset_dir),
            'imageCount': image_count,
            'labelCount': label_count
        })

    def handle_start_training(self):
        global training_state

        if training_state['running']:
            self.send_json({'success': False, 'error': '이미 학습이 진행 중입니다.'})
            return

        # Parse request body
        fresh_start = False
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length > 0:
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                fresh_start = data.get('fresh', False)
        except:
            pass

        mode_text = "🆕 새로 학습" if fresh_start else "🚀 이어서 학습"

        # Reset state
        training_state = {
            'running': True,
            'process': None,
            'log': f'{mode_text} 시작 중...\n',
            'completed': False,
            'success': False,
            'model_path': None
        }

        # Start training in background thread
        def run_training():
            global training_state
            try:
                dataset_path = TRAINING_DIR / 'barbell_plate_dataset_new' / 'data.yaml'

                if not dataset_path.exists():
                    training_state['log'] += f'\n오류: 데이터셋을 찾을 수 없습니다: {dataset_path}\n'
                    training_state['completed'] = True
                    training_state['running'] = False
                    return

                training_state['log'] += f'데이터셋: {dataset_path}\n'

                # 모델 선택
                base_model = "yolov8n.pt"  # 기본값

                if not fresh_start:
                    # 기존 학습 모델 찾기 (이어서 학습용)
                    runs_dir = TRAINING_DIR / 'runs' / 'detect'
                    if runs_dir.exists():
                        endpoint_dirs = sorted([d for d in runs_dir.iterdir()
                                              if d.is_dir() and d.name.startswith('barbell_endpoint')],
                                             key=lambda x: x.stat().st_mtime, reverse=True)
                        for d in endpoint_dirs:
                            best_pt = d / 'weights' / 'best.pt'
                            if best_pt.exists():
                                base_model = str(best_pt)
                                break

                if base_model == "yolov8n.pt":
                    model_msg = "기본 모델(yolov8n.pt)에서 새로 학습"
                else:
                    model_msg = f"기존 모델에서 이어서 학습: {Path(base_model).parent.parent.name}"
                training_state['log'] += f'{model_msg}\n\n'

                cmd = [
                    'python3', '-c', f'''
from ultralytics import YOLO
import sys

model = YOLO("{base_model}")
print("모델 로드 완료: {base_model}", flush=True)
print("학습 시작...", flush=True)

results = model.train(
    data="{dataset_path}",
    epochs=30,
    imgsz=320,
    batch=8,
    name="barbell_endpoint",
    patience=10,
    device="mps",
    workers=2,
    verbose=True,
    resume=False
)

print("\\n학습 완료!", flush=True)
print(f"Best model: {{results.save_dir}}/weights/best.pt", flush=True)
'''
                ]

                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    cwd=str(TRAINING_DIR)
                )

                training_state['process'] = process

                # Read output in real-time
                for line in iter(process.stdout.readline, ''):
                    if not training_state['running']:
                        process.terminate()
                        break
                    training_state['log'] += line
                    # Keep log size manageable
                    if len(training_state['log']) > 50000:
                        training_state['log'] = training_state['log'][-40000:]

                process.wait()

                if process.returncode == 0:
                    # 최신 학습 모델 찾기
                    latest_model = None
                    runs_dir = TRAINING_DIR / 'runs' / 'detect'
                    if runs_dir.exists():
                        endpoint_dirs = sorted([d for d in runs_dir.iterdir()
                                              if d.is_dir() and d.name.startswith('barbell_endpoint')],
                                             key=lambda x: x.stat().st_mtime, reverse=True)
                        for d in endpoint_dirs:
                            best_pt = d / 'weights' / 'best.pt'
                            if best_pt.exists():
                                latest_model = best_pt
                                break

                    training_state['success'] = True
                    training_state['model_path'] = str(latest_model) if latest_model else None
                    training_state['log'] += '\n\n✅ 학습이 성공적으로 완료되었습니다!\n'

                    # CoreML 변환 및 iOS 앱에 복사
                    if latest_model:
                        training_state['log'] += '\n📱 CoreML 변환 중...\n'
                        try:
                            from ultralytics import YOLO
                            model = YOLO(str(latest_model))
                            export_path = model.export(format='coreml', nms=True)
                            training_state['log'] += f'CoreML 변환 완료: {export_path}\n'

                            # iOS 앱에 복사
                            ios_model_path = TRAINING_DIR.parent / 'example' / 'ios' / 'Runner' / 'barbell_endpoint.mlpackage'
                            if Path(export_path).exists():
                                import shutil
                                if ios_model_path.exists():
                                    shutil.rmtree(ios_model_path)
                                shutil.copytree(export_path, ios_model_path)
                                training_state['log'] += f'✅ iOS 앱에 모델 복사 완료!\n'
                                training_state['log'] += f'   경로: {ios_model_path}\n'
                                training_state['log'] += f'\n⚠️ 앱을 다시 빌드해야 새 모델이 적용됩니다.\n'
                        except Exception as e:
                            training_state['log'] += f'CoreML 변환 실패: {str(e)}\n'
                else:
                    training_state['log'] += f'\n\n❌ 학습 실패 (exit code: {process.returncode})\n'

            except Exception as e:
                training_state['log'] += f'\n\n오류: {str(e)}\n'
                training_state['success'] = False

            finally:
                training_state['running'] = False
                training_state['completed'] = True
                training_state['process'] = None

        thread = threading.Thread(target=run_training)
        thread.daemon = True
        thread.start()

        self.send_json({'success': True})

    def get_training_status(self):
        global training_state
        return {
            'running': training_state['running'],
            'completed': training_state['completed'],
            'success': training_state['success'],
            'log': training_state['log'],
            'modelPath': training_state['model_path']
        }

    def handle_stop_training(self):
        global training_state

        training_state['running'] = False

        if training_state['process']:
            try:
                training_state['process'].terminate()
            except:
                pass

        training_state['log'] += '\n\n⏹ 사용자에 의해 학습이 중지되었습니다.\n'
        training_state['completed'] = True

        self.send_json({'success': True})

    def handle_start_auto_label(self):
        global auto_label_state

        if auto_label_state['running']:
            self.send_json({'success': False, 'error': '이미 자동 라벨링이 진행 중입니다.'})
            return

        # Find latest trained model
        model_path = None
        runs_dir = TRAINING_DIR / 'runs' / 'detect'
        if runs_dir.exists():
            # barbell 관련 폴더 중 가장 최근 것 찾기 (barbell_endpoint, barbell_augmented 등)
            barbell_dirs = sorted([d for d in runs_dir.iterdir()
                                  if d.is_dir() and d.name.startswith('barbell')],
                                 key=lambda x: x.stat().st_mtime, reverse=True)
            for d in barbell_dirs:
                best_pt = d / 'weights' / 'best.pt'
                if best_pt.exists():
                    model_path = best_pt
                    break

        if not model_path:
            self.send_json({'success': False, 'error': '학습된 모델이 없습니다. 먼저 학습을 진행하세요.'})
            return

        # Get unlabeled images
        unlabeled = []
        for f in IMAGES_DIR.glob('*'):
            if f.suffix.lower() in ['.jpg', '.jpeg', '.png']:
                label_path = LABELS_DIR / f'{f.stem}.txt'
                if not label_path.exists():
                    unlabeled.append(f)

        if not unlabeled:
            self.send_json({'success': False, 'error': '라벨링되지 않은 이미지가 없습니다.'})
            return

        # Reset state
        auto_label_state = {
            'running': True,
            'completed': False,
            'total': len(unlabeled),
            'processed': 0,
            'labeled': 0,
            'log': f'모델: {model_path.name}\n총 {len(unlabeled)}개 이미지 처리 예정\n\n'
        }

        # Run in background thread
        def run_auto_label():
            global auto_label_state
            try:
                from ultralytics import YOLO
                model = YOLO(str(model_path))
                auto_label_state['log'] += '모델 로드 완료\n\n'

                LABELS_DIR.mkdir(exist_ok=True)

                for i, img_path in enumerate(unlabeled):
                    if not auto_label_state['running']:
                        auto_label_state['log'] += '\n⏹ 사용자에 의해 중지됨\n'
                        break

                    # Predict
                    results = model(str(img_path), verbose=False, conf=0.3)

                    # Save labels
                    label_path = LABELS_DIR / f'{img_path.stem}.txt'
                    label_count = 0

                    with open(label_path, 'w') as f:
                        for result in results:
                            if result.boxes is not None:
                                for box in result.boxes:
                                    # Get normalized coordinates
                                    x1, y1, x2, y2 = box.xyxyn[0].tolist()
                                    cx = (x1 + x2) / 2
                                    cy = (y1 + y2) / 2
                                    w = x2 - x1
                                    h = y2 - y1
                                    conf = box.conf[0].item()

                                    f.write(f'0 {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n')
                                    label_count += 1
                                    auto_label_state['labeled'] += 1

                    # Mark as auto label
                    if label_count > 0:
                        meta = load_label_metadata()
                        meta[img_path.stem] = 'auto'
                        save_label_metadata(meta)

                    auto_label_state['processed'] = i + 1
                    auto_label_state['log'] += f'[{i+1}/{len(unlabeled)}] {img_path.name}: {label_count}개 감지\n'

                auto_label_state['log'] += f'\n\n✅ 완료! {auto_label_state["labeled"]}개 라벨 생성\n'

            except Exception as e:
                auto_label_state['log'] += f'\n\n❌ 오류: {str(e)}\n'

            finally:
                auto_label_state['running'] = False
                auto_label_state['completed'] = True

        thread = threading.Thread(target=run_auto_label)
        thread.daemon = True
        thread.start()

        self.send_json({'success': True})

    def get_auto_label_status(self):
        global auto_label_state
        return {
            'running': auto_label_state['running'],
            'completed': auto_label_state['completed'],
            'total': auto_label_state['total'],
            'processed': auto_label_state['processed'],
            'labeled': auto_label_state['labeled'],
            'log': auto_label_state['log']
        }

    def handle_stop_auto_label(self):
        global auto_label_state
        auto_label_state['running'] = False
        self.send_json({'success': True})

    def handle_claude_label_single(self):
        """Claude API로 단일 이미지 라벨링"""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        data = json.loads(body)

        image_name = data.get('imageName')
        api_key = data.get('apiKey')

        if not image_name or not api_key:
            self.send_json({'success': False, 'error': '이미지 이름과 API 키가 필요합니다.'})
            return

        image_path = IMAGES_DIR / image_name

        if not image_path.exists():
            self.send_json({'success': False, 'error': f'이미지를 찾을 수 없습니다: {image_name}'})
            return

        try:
            import anthropic
            import base64

            # Read and encode image
            with open(image_path, 'rb') as f:
                image_data = base64.standard_b64encode(f.read()).decode('utf-8')

            # Determine media type
            suffix = image_path.suffix.lower()
            media_type = 'image/jpeg' if suffix in ['.jpg', '.jpeg'] else 'image/png'

            # Call Claude API
            client = anthropic.Anthropic(api_key=api_key)

            message = client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=1024,
                messages=[{
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": image_data
                            }
                        },
                        {
                            "type": "text",
                            "text": """이 이미지에서 바벨(barbell) 플레이트의 끝단(옆면, 원형 부분)을 찾아주세요.

바벨 플레이트 끝단은 바벨의 양쪽 끝에 있는 원형 무게판의 옆면입니다.

각 끝단에 대해 바운딩 박스 좌표를 다음 형식으로 반환해주세요:
- cx: 중심 x좌표 (0~1, 이미지 너비 기준)
- cy: 중심 y좌표 (0~1, 이미지 높이 기준)
- w: 너비 (0~1)
- h: 높이 (0~1)

JSON 형식으로만 응답해주세요:
{"labels": [{"cx": 0.2, "cy": 0.5, "w": 0.1, "h": 0.15}, ...]}

바벨이 보이지 않으면: {"labels": []}"""
                        }
                    ]
                }]
            )

            # Parse response
            response_text = message.content[0].text
            log = f"Claude 응답:\n{response_text}\n"

            # Extract JSON from response
            import re
            json_match = re.search(r'\{.*\}', response_text, re.DOTALL)

            if json_match:
                result = json.loads(json_match.group())
                labels = result.get('labels', [])

                # Save labels
                LABELS_DIR.mkdir(exist_ok=True)
                stem = image_path.stem
                label_path = LABELS_DIR / f'{stem}.txt'

                with open(label_path, 'w') as f:
                    for label in labels:
                        cx = label.get('cx', 0)
                        cy = label.get('cy', 0)
                        w = label.get('w', 0.05)
                        h = label.get('h', 0.05)
                        f.write(f'0 {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n')

                # Mark as claude label
                meta = load_label_metadata()
                meta[stem] = 'claude'
                save_label_metadata(meta)

                log += f"\n✅ {len(labels)}개 라벨 저장됨"

                self.send_json({
                    'success': True,
                    'labelCount': len(labels),
                    'log': log
                })
            else:
                self.send_json({
                    'success': False,
                    'error': 'Claude 응답에서 JSON을 파싱할 수 없습니다.',
                    'log': log
                })

        except ImportError:
            self.send_json({
                'success': False,
                'error': 'anthropic 패키지가 설치되지 않았습니다. pip install anthropic'
            })
        except Exception as e:
            self.send_json({
                'success': False,
                'error': str(e)
            })

    def handle_claude_label_batch(self):
        """Claude API로 여러 이미지 일괄 라벨링"""
        global claude_label_state

        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        data = json.loads(body)

        api_key = data.get('apiKey')

        if not api_key:
            self.send_json({'success': False, 'error': 'API 키가 필요합니다.'})
            return

        if claude_label_state['running']:
            self.send_json({'success': False, 'error': '이미 Claude 라벨링이 진행 중입니다.'})
            return

        # Get unlabeled images
        unlabeled = []
        for f in IMAGES_DIR.glob('*'):
            if f.suffix.lower() in ['.jpg', '.jpeg', '.png']:
                label_path = LABELS_DIR / f'{f.stem}.txt'
                if not label_path.exists():
                    unlabeled.append(f)

        if not unlabeled:
            self.send_json({'success': False, 'error': '라벨링되지 않은 이미지가 없습니다.'})
            return

        # Limit to prevent API overuse
        max_images = min(len(unlabeled), 50)
        unlabeled = unlabeled[:max_images]

        # Reset state
        claude_label_state = {
            'running': True,
            'completed': False,
            'total': len(unlabeled),
            'processed': 0,
            'labeled': 0,
            'log': f'Claude AI 라벨링 시작\n총 {len(unlabeled)}개 이미지 (최대 50개)\n\n'
        }

        # Run in background
        def run_claude_label():
            global claude_label_state
            try:
                import anthropic
                import base64

                client = anthropic.Anthropic(api_key=api_key)
                claude_label_state['log'] += 'API 연결 성공\n\n'

                LABELS_DIR.mkdir(exist_ok=True)

                for i, img_path in enumerate(unlabeled):
                    if not claude_label_state['running']:
                        claude_label_state['log'] += '\n⏹ 사용자에 의해 중지됨\n'
                        break

                    try:
                        # Read and encode image
                        with open(img_path, 'rb') as f:
                            image_data = base64.standard_b64encode(f.read()).decode('utf-8')

                        suffix = img_path.suffix.lower()
                        media_type = 'image/jpeg' if suffix in ['.jpg', '.jpeg'] else 'image/png'

                        # Call Claude
                        message = client.messages.create(
                            model="claude-sonnet-4-20250514",
                            max_tokens=512,
                            messages=[{
                                "role": "user",
                                "content": [
                                    {
                                        "type": "image",
                                        "source": {
                                            "type": "base64",
                                            "media_type": media_type,
                                            "data": image_data
                                        }
                                    },
                                    {
                                        "type": "text",
                                        "text": """바벨 플레이트 끝단(원형 옆면)의 바운딩 박스 좌표를 JSON으로 반환하세요.
형식: {"labels": [{"cx": 0.2, "cy": 0.5, "w": 0.1, "h": 0.15}]}
바벨이 없으면: {"labels": []}
JSON만 응답하세요."""
                                    }
                                ]
                            }]
                        )

                        response_text = message.content[0].text

                        # Parse JSON
                        import re
                        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)

                        label_count = 0
                        if json_match:
                            result = json.loads(json_match.group())
                            labels = result.get('labels', [])

                            # Save labels
                            label_path = LABELS_DIR / f'{img_path.stem}.txt'
                            with open(label_path, 'w') as f:
                                for label in labels:
                                    cx = label.get('cx', 0)
                                    cy = label.get('cy', 0)
                                    w = label.get('w', 0.05)
                                    h = label.get('h', 0.05)
                                    f.write(f'0 {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n')
                                    label_count += 1
                                    claude_label_state['labeled'] += 1

                            # Mark as claude
                            if label_count > 0:
                                meta = load_label_metadata()
                                meta[img_path.stem] = 'claude'
                                save_label_metadata(meta)

                        claude_label_state['processed'] = i + 1
                        claude_label_state['log'] += f'[{i+1}/{len(unlabeled)}] {img_path.name}: {label_count}개\n'

                    except Exception as e:
                        claude_label_state['log'] += f'[{i+1}/{len(unlabeled)}] {img_path.name}: 오류 - {str(e)[:50]}\n'
                        claude_label_state['processed'] = i + 1

                claude_label_state['log'] += f'\n\n✅ 완료! {claude_label_state["labeled"]}개 라벨 생성\n'

            except Exception as e:
                claude_label_state['log'] += f'\n\n❌ 오류: {str(e)}\n'

            finally:
                claude_label_state['running'] = False
                claude_label_state['completed'] = True

        thread = threading.Thread(target=run_claude_label)
        thread.daemon = True
        thread.start()

        self.send_json({'success': True})

    def get_claude_label_status(self):
        global claude_label_state
        return {
            'running': claude_label_state['running'],
            'completed': claude_label_state['completed'],
            'total': claude_label_state['total'],
            'processed': claude_label_state['processed'],
            'labeled': claude_label_state['labeled'],
            'log': claude_label_state['log']
        }

    def handle_stop_claude_label(self):
        global claude_label_state
        claude_label_state['running'] = False
        self.send_json({'success': True})

    def handle_delete_labels(self):
        """다중 라벨 삭제"""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))

            image_names = data.get('images', [])
            meta = load_label_metadata()

            deleted = 0
            for name in image_names:
                # 확장자 제거
                stem = Path(name).stem if '.' in name else name
                label_path = LABELS_DIR / f'{stem}.txt'
                if label_path.exists():
                    label_path.unlink()
                    deleted += 1
                # 메타데이터에서도 삭제
                if stem in meta:
                    del meta[stem]

            save_label_metadata(meta)

            self.send_json({'success': True, 'deleted': deleted})

        except Exception as e:
            self.send_json({'success': False, 'error': str(e)})

    def log_message(self, format, *args):
        # Suppress default logging
        pass


def main():
    global PORT

    if len(sys.argv) > 1:
        PORT = int(sys.argv[1])

    IMAGES_DIR.mkdir(exist_ok=True)
    LABELS_DIR.mkdir(exist_ok=True)

    print(f'''
{'='*60}
🏋️ 바벨 끝단 웹 라벨링 서버
{'='*60}

서버 시작: http://localhost:{PORT}

이미지 폴더: {IMAGES_DIR}
라벨 폴더: {LABELS_DIR}

사용법:
1. 브라우저에서 http://localhost:{PORT} 접속
2. 이미지 업로드 또는 "크롤링 이미지 불러오기" 클릭
3. 바벨 플레이트 끝단을 드래그하여 라벨링
4. "데이터셋 Export" 클릭하여 학습용 데이터셋 생성

단축키:
  A/← : 이전 이미지
  D/→ : 다음 이미지
  S   : 저장
  Z   : 실행취소 (마지막 라벨 삭제)

Ctrl+C로 서버 종료
{'='*60}
''')

    with socketserver.TCPServer(('', PORT), LabelingHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print('\n서버 종료')


if __name__ == '__main__':
    import sys
    main()
