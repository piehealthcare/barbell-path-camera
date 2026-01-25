#!/usr/bin/env python3
"""
증강된 데이터로 YOLO 모델 학습
"""

import os
import shutil
import random
from pathlib import Path
from ultralytics import YOLO

TRAINING_DIR = Path(__file__).parent
AUGMENTED_IMAGES = TRAINING_DIR / 'augmented_images'
AUGMENTED_LABELS = TRAINING_DIR / 'augmented_labels'
DATASET_DIR = TRAINING_DIR / 'augmented_dataset'

def prepare_dataset(train_ratio=0.85):
    """데이터셋 준비 (train/val 분할)"""
    # 디렉토리 생성
    for split in ['train', 'val']:
        (DATASET_DIR / 'images' / split).mkdir(parents=True, exist_ok=True)
        (DATASET_DIR / 'labels' / split).mkdir(parents=True, exist_ok=True)

    # 이미지-라벨 쌍 수집
    pairs = []
    for img_path in AUGMENTED_IMAGES.glob('*'):
        if img_path.suffix.lower() not in ['.jpg', '.jpeg', '.png']:
            continue
        label_path = AUGMENTED_LABELS / f"{img_path.stem}.txt"
        if label_path.exists():
            pairs.append((img_path, label_path))

    print(f"총 이미지-라벨 쌍: {len(pairs)}개")

    # 셔플 후 분할
    random.shuffle(pairs)
    split_idx = int(len(pairs) * train_ratio)
    train_pairs = pairs[:split_idx]
    val_pairs = pairs[split_idx:]

    print(f"Train: {len(train_pairs)}개, Val: {len(val_pairs)}개")

    # 파일 복사
    for img_path, label_path in train_pairs:
        shutil.copy(img_path, DATASET_DIR / 'images' / 'train' / img_path.name)
        shutil.copy(label_path, DATASET_DIR / 'labels' / 'train' / label_path.name)

    for img_path, label_path in val_pairs:
        shutil.copy(img_path, DATASET_DIR / 'images' / 'val' / img_path.name)
        shutil.copy(label_path, DATASET_DIR / 'labels' / 'val' / label_path.name)

    # data.yaml 생성
    yaml_content = f"""path: {DATASET_DIR}
train: images/train
val: images/val

names:
  0: barbell_endpoint
"""
    (DATASET_DIR / 'data.yaml').write_text(yaml_content)
    print(f"data.yaml 생성: {DATASET_DIR / 'data.yaml'}")

    return DATASET_DIR / 'data.yaml'

def train_model(data_yaml):
    """YOLO 모델 학습"""
    model = YOLO('yolov8n.pt')

    results = model.train(
        data=str(data_yaml),
        epochs=100,
        imgsz=640,
        batch=16,
        patience=15,
        name='barbell_augmented',
        device='mps',  # Apple Silicon
        verbose=True,
    )

    return results

def export_model():
    """CoreML로 내보내기"""
    # 최신 학습 결과 찾기
    runs_dir = TRAINING_DIR / 'runs' / 'detect'
    latest_run = max(runs_dir.glob('barbell_augmented*'), key=os.path.getmtime)
    best_model = latest_run / 'weights' / 'best.pt'

    print(f"최적 모델: {best_model}")

    model = YOLO(str(best_model))
    model.export(format='coreml', nms=True)

    # mlpackage 경로
    mlpackage = best_model.parent / 'best.mlpackage'
    print(f"CoreML 모델: {mlpackage}")

    return mlpackage

if __name__ == '__main__':
    print("=== 1. 데이터셋 준비 ===")
    data_yaml = prepare_dataset()

    print("\n=== 2. 모델 학습 ===")
    train_model(data_yaml)

    print("\n=== 3. CoreML 내보내기 ===")
    mlpackage = export_model()

    print("\n=== 완료 ===")
    print(f"CoreML 모델 경로: {mlpackage}")
