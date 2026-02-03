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
  1: barbell_collar
"""
    (DATASET_DIR / 'data.yaml').write_text(yaml_content)

    return DATASET_DIR / 'data.yaml'

def finetune_model(data_yaml, base_model, use_yolov8s=False, high_res=False):
    """Fine-tuning: 기존 모델에서 이어서 학습"""

    # YOLOv8s로 업그레이드 시 새 모델에서 시작
    if use_yolov8s:
        print("\n=== YOLOv8s 모델로 업그레이드 ===")
        model = YOLO('yolov8s.pt')
    else:
        print(f"\n기존 모델에서 Fine-tuning: {base_model}")
        model = YOLO(str(base_model))

    # 해상도 설정 (1280은 메모리 많이 사용)
    img_size = 1280 if high_res else 640
    batch_size = 8 if high_res else 16  # 고해상도 시 배치 줄임

    print(f"해상도: {img_size}, 배치: {batch_size}")

    results = model.train(
        data=str(data_yaml),
        epochs=50,  # 새 모델이므로 에포크 증가
        imgsz=img_size,
        batch=batch_size,
        patience=15,
        name='barbell_yolov8s_hires' if high_res else ('barbell_yolov8s' if use_yolov8s else 'barbell_finetuned'),
        device='mps',
        verbose=True,
        lr0=0.01 if use_yolov8s else 0.001,  # 새 모델은 높은 학습률
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
    import sys

    # 옵션: --upgrade (YOLOv8s 사용), --hires (1280 해상도)
    use_yolov8s = '--upgrade' in sys.argv
    high_res = '--hires' in sys.argv

    print("=== 1. 설정 확인 ===")
    print(f"  모델: {'YOLOv8s (업그레이드)' if use_yolov8s else 'Fine-tuning'}")
    print(f"  해상도: {'1280 (고해상도)' if high_res else '640'}")

    print("\n=== 2. 기존 모델 찾기 ===")
    base_model = find_best_model()

    if base_model:
        print(f"기존 모델 발견: {base_model}")
    else:
        print("기존 모델 없음")
        base_model = None

    print("\n=== 3. 데이터셋 준비 ===")
    data_yaml = prepare_dataset()

    print("\n=== 4. 학습 시작 ===")
    finetune_model(data_yaml, base_model, use_yolov8s=use_yolov8s, high_res=high_res)

    print("\n=== 5. CoreML 내보내기 ===")
    mlpackage = export_model()

    print("\n=== 완료 ===")
    print(f"CoreML 모델 경로: {mlpackage}")
