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
PORT = 8080
TRAINING_DIR = Path(__file__).parent
IMAGES_DIR = TRAINING_DIR / "labeling_images"
LABELS_DIR = TRAINING_DIR / "labeling_labels"
CLASS_NAME = "barbell_plate_side"

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
                <div class="stat-value" id="labeledImages">0</div>
                <div class="stat-label">라벨링 완료</div>
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
                    📦 데이터셋 Export
                </button>

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
            <p><strong>학습 명령어:</strong></p>
            <code>cd training && python3 -c "
from ultralytics import YOLO
model = YOLO('yolov8n.pt')
model.train(data='barbell_plate_dataset_new/data.yaml', epochs=100, imgsz=320, device='mps')
"</code>
            <button class="btn btn-primary" onclick="closeModal()">확인</button>
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
            document.getElementById('labeledImages').textContent = data.labeled;
            document.getElementById('totalLabels').textContent = data.totalLabels;

            const progress = data.total > 0 ? (data.labeled / data.total * 100) : 0;
            document.getElementById('progressFill').style.width = progress + '%';
        }

        function renderImageList() {
            const container = document.getElementById('imageList');

            if (images.length === 0) {
                container.innerHTML = '<div class="empty-state"><div>이미지를 업로드하세요</div></div>';
                return;
            }

            container.innerHTML = images.map((img, i) => `
                <div class="image-item ${i === currentIndex ? 'active' : ''} ${img.labelCount > 0 ? 'labeled' : ''}"
                     onclick="selectImage(${i})">
                    <img class="image-thumb" src="/images/${img.name}" alt="">
                    <span class="image-name">${img.name}</span>
                    ${img.labelCount > 0 ? `<span class="label-count">${img.labelCount}</span>` : ''}
                </div>
            `).join('');
        }

        async function selectImage(index) {
            // Save current labels before switching
            if (currentIndex >= 0 && currentLabels.length > 0) {
                await saveLabels(false);
            }

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

                // Box
                ctx.strokeStyle = '#00ff88';
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

                // Label number
                ctx.fillStyle = '#00ff88';
                ctx.font = 'bold 14px sans-serif';
                ctx.fillText(`#${i + 1}`, x + 4, y - 4);
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
                saveLabels(false);  // 서버에도 저장 (빈 라벨)
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

            container.innerHTML = currentLabels.map((label, i) => `
                <div class="label-item">
                    <span>#${i + 1}: (${(label.cx * 100).toFixed(1)}%, ${(label.cy * 100).toFixed(1)}%)</span>
                    <span class="delete-label" onclick="deleteLabel(${i})">✕</span>
                </div>
            `).join('');
        }

        async function saveLabels(showAlert = true) {
            if (currentIndex < 0) return;

            const imageName = images[currentIndex].name;

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
                loadImageList();
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

        for f in sorted(IMAGES_DIR.glob('*')):
            if f.suffix.lower() in ['.jpg', '.jpeg', '.png', '.bmp', '.webp']:
                label_path = LABELS_DIR / f'{f.stem}.txt'
                label_count = 0

                if label_path.exists():
                    with open(label_path) as lf:
                        label_count = len([l for l in lf.readlines() if l.strip()])

                images.append({
                    'name': f.name,
                    'labelCount': label_count
                })

                total_labels += label_count
                if label_count > 0:
                    labeled_count += 1

        return {
            'images': images,
            'total': len(images),
            'labeled': labeled_count,
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
                        _, cx, cy, w, h = parts[:5]
                        labels.append({
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
                cx = label['cx']
                cy = label['cy']
                w = label['w']
                h = label['h']
                f.write(f'0 {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n')

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
        yaml_content = f"""# Barbell Plate Side Dataset
# Generated by labeling_server.py
# Total images: {image_count} (train: {len(train_set)}, valid: {len(valid_set)})
# Total labels: {label_count}

path: {dataset_dir.absolute()}
train: train/images
val: valid/images

names:
  0: {CLASS_NAME}

nc: 1
"""
        (dataset_dir / 'data.yaml').write_text(yaml_content)

        print(f"Dataset exported: {image_count} images, {label_count} labels")

        self.send_json({
            'success': True,
            'path': str(dataset_dir),
            'imageCount': image_count,
            'labelCount': label_count
        })

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
