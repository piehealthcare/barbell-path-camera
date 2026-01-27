#!/usr/bin/env python3
"""
기존 모델에서 이어서 학습 (Fine-tuning)
- 이전 best.pt에서 시작
- 더 적은 에포크로 빠르게 학습
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

def find_best_model():
    """가장 최근 학습된 best.pt 찾기"""
    runs_dir = TRAINING_DIR / 'runs' / 'detect'
    if not runs_dir.exists():
        return None

    # barbell 관련 폴더 중 가장 최근 것
    barbell_dirs = sorted(
        [d for d in runs_dir.iterdir() if d.is_dir() and d.name.startswith('barbell')],
        key=lambda x: x.stat().st_mtime,
        reverse=True
    )

    for d in barbell_dirs:
        best_pt = d / 'weights' / 'best.pt'
        if best_pt.exists():
            return best_pt
    return None

def prepare_dataset(train_ratio=0.85):
    """데이터셋 준비 (train/val 분할)"""
    for split in ['train', 'val']:
        (DATASET_DIR / 'images' / split).mkdir(parents=True, exist_ok=True)
        (DATASET_DIR / 'labels' / split).mkdir(parents=True, exist_ok=True)

    # 기존 파일 삭제
    for split in ['train', 'val']:
        for f in (DATASET_DIR / 'images' / split).glob('*'):
            f.unlink()
        for f in (DATASET_DIR / 'labels' / split).glob('*'):
            f.unlink()

    pairs = []
    for img_path in AUGMENTED_IMAGES.glob('*'):
        if img_path.suffix.lower() not in ['.jpg', '.jpeg', '.png']:
            continue
        label_path = AUGMENTED_LABELS / f"{img_path.stem}.txt"
        if label_path.exists():
            pairs.append((img_path, label_path))

    print(f"총 이미지-라벨 쌍: {len(pairs)}개")

    random.shuffle(pairs)
    split_idx = int(len(pairs) * train_ratio)
    train_pairs = pairs[:split_idx]
    val_pairs = pairs[split_idx:]

    print(f"Train: {len(train_pairs)}개, Val: {len(val_pairs)}개")

    for img_path, label_path in train_pairs:
        shutil.copy(img_path, DATASET_DIR / 'images' / 'train' / img_path.name)
        shutil.copy(label_path, DATASET_DIR / 'labels' / 'train' / label_path.name)

    for img_path, label_path in val_pairs:
        shutil.copy(img_path, DATASET_DIR / 'images' / 'val' / img_path.name)
        shutil.copy(label_path, DATASET_DIR / 'labels' / 'val' / label_path.name)

    yaml_content = f"""path: {DATASET_DIR}
train: images/train
val: images/val

names:
  0: barbell_endpoint
"""
    (DATASET_DIR / 'data.yaml').write_text(yaml_content)

    return DATASET_DIR / 'data.yaml'

def finetune_model(data_yaml, base_model):
    """Fine-tuning: 기존 모델에서 이어서 학습"""
    print(f"\n기존 모델에서 Fine-tuning: {base_model}")

    model = YOLO(str(base_model))

    results = model.train(
        data=str(data_yaml),
        epochs=30,  # Fine-tuning은 적은 에포크
        imgsz=640,
        batch=16,
        patience=10,
        name='barbell_finetuned',
        device='mps',
        verbose=True,
        lr0=0.001,  # 낮은 학습률로 fine-tuning
    )

    return results

def export_model():
    """CoreML로 내보내기"""
    runs_dir = TRAINING_DIR / 'runs' / 'detect'
    latest_run = max(runs_dir.glob('barbell_finetuned*'), key=os.path.getmtime)
    best_model = latest_run / 'weights' / 'best.pt'

    print(f"최적 모델: {best_model}")

    model = YOLO(str(best_model))
    model.export(format='coreml', nms=True)

    mlpackage = best_model.parent / 'best.mlpackage'
    print(f"CoreML 모델: {mlpackage}")

    return mlpackage

if __name__ == '__main__':
    print("=== 1. 기존 모델 찾기 ===")
    base_model = find_best_model()

    if base_model:
        print(f"기존 모델 발견: {base_model}")
    else:
        print("기존 모델 없음, yolov8n.pt에서 시작")
        base_model = "yolov8n.pt"

    print("\n=== 2. 데이터셋 준비 ===")
    data_yaml = prepare_dataset()

    print("\n=== 3. Fine-tuning 시작 ===")
    finetune_model(data_yaml, base_model)

    print("\n=== 4. CoreML 내보내기 ===")
    mlpackage = export_model()

    print("\n=== 완료 ===")
    print(f"CoreML 모델 경로: {mlpackage}")
