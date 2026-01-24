#!/usr/bin/env python3
"""
바벨 감지 모델 재학습 스크립트
- Negative samples (background 이미지) 추가
- False Positive 감소를 위한 학습
"""

import os
import shutil
from pathlib import Path
import urllib.request
import random

# 경로 설정
TRAINING_DIR = Path(__file__).parent
DATASET_DIR = TRAINING_DIR / "barbell_dataset"
TRAIN_IMAGES_DIR = DATASET_DIR / "train" / "images"
TRAIN_LABELS_DIR = DATASET_DIR / "train" / "labels"

def download_background_images():
    """
    Background 이미지 다운로드 (바벨이 없는 체육관 이미지)
    Unsplash에서 무료 이미지 다운로드
    """
    print("=== Background 이미지 다운로드 ===")

    # Unsplash 무료 이미지 URL (체육관 관련)
    background_urls = [
        # 체육관 바닥/벽
        ("https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=640", "gym_bg_1.jpg"),
        ("https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=640", "gym_bg_2.jpg"),
        ("https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=640", "gym_bg_3.jpg"),
        # 러닝머신/자전거 (바벨 아님)
        ("https://images.unsplash.com/photo-1576678927484-cc907957088c?w=640", "treadmill_1.jpg"),
        ("https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=640", "gym_equipment_1.jpg"),
        # 일반 실내
        ("https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=640", "person_gym_1.jpg"),
        ("https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=640", "empty_gym_1.jpg"),
        # 손/팔 (바벨 없음)
        ("https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=640", "hands_1.jpg"),
        ("https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=640", "workout_1.jpg"),
        ("https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=640", "stretching_1.jpg"),
    ]

    downloaded = 0
    for url, filename in background_urls:
        output_path = TRAIN_IMAGES_DIR / filename
        label_path = TRAIN_LABELS_DIR / filename.replace(".jpg", ".txt")

        if output_path.exists():
            print(f"  이미 존재: {filename}")
            continue

        try:
            print(f"  다운로드 중: {filename}")
            urllib.request.urlretrieve(url, output_path)

            # 빈 레이블 파일 생성 (background = 객체 없음)
            label_path.touch()

            downloaded += 1
        except Exception as e:
            print(f"  다운로드 실패: {filename} - {e}")

    print(f"  다운로드 완료: {downloaded}개")
    return downloaded

def create_synthetic_negatives():
    """
    기존 이미지에서 crop하여 synthetic negative 생성
    """
    print("\n=== Synthetic Negative 생성 ===")

    # 기존 이미지 목록
    existing_images = list(TRAIN_IMAGES_DIR.glob("*.jpg")) + list(TRAIN_IMAGES_DIR.glob("*.png"))

    # Random crop으로 negative 생성 (간단한 방법)
    # 실제로는 바벨 영역을 제외한 crop이 필요하지만, 여기서는 간단히 처리

    print(f"  기존 이미지: {len(existing_images)}개")
    print("  (추가 synthetic negative 생성은 수동으로 진행 권장)")

def train_model():
    """
    YOLOv8 모델 재학습
    """
    print("\n=== YOLOv8 모델 학습 시작 ===")

    try:
        from ultralytics import YOLO
    except ImportError:
        print("ultralytics 패키지 설치 필요: pip install ultralytics")
        return None

    # 데이터셋 경로 확인
    data_yaml = DATASET_DIR / "data.yaml"
    if not data_yaml.exists():
        print(f"data.yaml 파일 없음: {data_yaml}")
        return None

    # YOLOv8 nano 모델 로드
    model = YOLO("yolov8n.pt")

    # 학습 실행
    results = model.train(
        data=str(data_yaml),
        epochs=100,          # 에포크 수 증가
        imgsz=320,           # 모바일용 이미지 크기
        batch=16,
        name="barbell_detector_v2",
        patience=20,         # Early stopping
        device="mps",        # Apple Silicon GPU (없으면 cpu로 변경)
        workers=4,
        # 추가 설정
        lr0=0.01,            # 초기 학습률
        lrf=0.01,            # 최종 학습률
        warmup_epochs=3,     # Warmup 에포크
        box=7.5,             # Box loss gain
        cls=0.5,             # Class loss gain
        # Augmentation
        hsv_h=0.015,
        hsv_s=0.7,
        hsv_v=0.4,
        degrees=10,
        translate=0.1,
        scale=0.5,
        flipud=0.5,          # 상하 반전 (바벨 트래킹에 유용)
        mosaic=1.0,
    )

    print("\n=== 학습 완료 ===")
    return model

def export_models(model):
    """
    CoreML 및 TFLite로 export
    """
    print("\n=== 모델 Export ===")

    if model is None:
        # 기존 best 모델 로드
        best_model_path = TRAINING_DIR / "runs" / "detect" / "barbell_detector_v2" / "weights" / "best.pt"
        if not best_model_path.exists():
            print("학습된 모델 없음")
            return

        from ultralytics import YOLO
        model = YOLO(str(best_model_path))

    # CoreML export (iOS용)
    print("  CoreML 모델 생성 중...")
    model.export(
        format="coreml",
        imgsz=320,
        half=True,
        nms=True,  # NMS 포함 (중요!)
    )

    # TFLite export (Android용)
    print("  TFLite 모델 생성 중...")
    model.export(
        format="tflite",
        imgsz=320,
        half=True,
    )

    print("  Export 완료!")

def copy_models_to_app():
    """
    생성된 모델을 앱 폴더로 복사
    """
    print("\n=== 모델 복사 ===")

    runs_dir = TRAINING_DIR / "runs" / "detect" / "barbell_detector_v2" / "weights"

    # CoreML 모델
    coreml_src = runs_dir / "best.mlpackage"
    coreml_dst = TRAINING_DIR.parent / "example" / "ios" / "Runner" / "barbell_detector.mlpackage"

    if coreml_src.exists():
        if coreml_dst.exists():
            shutil.rmtree(coreml_dst)
        shutil.copytree(coreml_src, coreml_dst)
        print(f"  CoreML 복사 완료: {coreml_dst}")

    # TFLite 모델
    tflite_src = runs_dir / "best_float16.tflite"
    tflite_dst = TRAINING_DIR.parent / "barbell_tracking" / "assets" / "ml" / "barbell_detector.tflite"

    if tflite_src.exists():
        shutil.copy2(tflite_src, tflite_dst)
        print(f"  TFLite 복사 완료: {tflite_dst}")

def main():
    print("=" * 50)
    print("바벨 감지 모델 재학습")
    print("=" * 50)

    # 1. Background 이미지 다운로드
    download_background_images()

    # 2. Synthetic negative 생성 (옵션)
    create_synthetic_negatives()

    # 3. 현재 데이터셋 상태
    train_images = list(TRAIN_IMAGES_DIR.glob("*.jpg")) + list(TRAIN_IMAGES_DIR.glob("*.png"))
    print(f"\n현재 학습 이미지 수: {len(train_images)}")

    # 4. 모델 학습
    model = train_model()

    # 5. 모델 Export
    export_models(model)

    # 6. 앱으로 복사
    copy_models_to_app()

    print("\n" + "=" * 50)
    print("재학습 완료!")
    print("=" * 50)

if __name__ == "__main__":
    main()
