#!/usr/bin/env python3
"""
라벨링 데이터 증강 스크립트
- 수동 라벨링만 사용
- 밝기/대비 변화
- 모션블러
- 좌우 반전
- 색상 변화
"""

import cv2
import numpy as np
from pathlib import Path
import shutil
import json

TRAINING_DIR = Path(__file__).parent
IMAGES_DIR = TRAINING_DIR / 'labeling_images'
LABELS_DIR = TRAINING_DIR / 'labeling_labels'
METADATA_FILE = LABELS_DIR / '_metadata.json'
OUTPUT_IMAGES_DIR = TRAINING_DIR / 'augmented_images'
OUTPUT_LABELS_DIR = TRAINING_DIR / 'augmented_labels'

def get_matched_pairs():
    """라벨링된 이미지-라벨 쌍 찾기 (비어있지 않은 라벨만)"""
    pairs = []
    for img_path in IMAGES_DIR.glob('*'):
        if img_path.suffix.lower() not in ['.jpg', '.jpeg', '.png', '.webp']:
            continue

        label_path = LABELS_DIR / f"{img_path.stem}.txt"
        if label_path.exists():
            # 라벨 파일이 비어있지 않은지 확인
            content = label_path.read_text().strip()
            if content:
                pairs.append((img_path, label_path))

    return pairs

def apply_brightness_contrast(img, alpha=1.0, beta=0):
    """밝기/대비 조절"""
    return cv2.convertScaleAbs(img, alpha=alpha, beta=beta)

def apply_motion_blur(img, size=5):
    """모션 블러 (수직 방향 - 바벨 움직임)"""
    kernel = np.zeros((size, size))
    kernel[:, size // 2] = 1 / size
    return cv2.filter2D(img, -1, kernel)

def apply_horizontal_flip(img, labels):
    """좌우 반전 + 라벨 좌표 변환"""
    flipped_img = cv2.flip(img, 1)

    new_labels = []
    for label in labels:
        parts = label.strip().split()
        if len(parts) >= 5:
            cls, x, y, w, h = parts[0], float(parts[1]), float(parts[2]), float(parts[3]), float(parts[4])
            # x 좌표 반전
            new_x = 1.0 - x
            new_labels.append(f"{cls} {new_x:.6f} {y:.6f} {w:.6f} {h:.6f}")

    return flipped_img, new_labels

def apply_color_jitter(img):
    """색상 변화"""
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV).astype(np.float32)

    # 색조 변화
    hsv[:, :, 0] += np.random.uniform(-10, 10)
    hsv[:, :, 0] = np.clip(hsv[:, :, 0], 0, 179)

    # 채도 변화
    hsv[:, :, 1] *= np.random.uniform(0.8, 1.2)
    hsv[:, :, 1] = np.clip(hsv[:, :, 1], 0, 255)

    # 명도 변화
    hsv[:, :, 2] *= np.random.uniform(0.8, 1.2)
    hsv[:, :, 2] = np.clip(hsv[:, :, 2], 0, 255)

    return cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)

def apply_gaussian_noise(img, var=10):
    """가우시안 노이즈"""
    noise = np.random.normal(0, var, img.shape).astype(np.float32)
    noisy = img.astype(np.float32) + noise
    return np.clip(noisy, 0, 255).astype(np.uint8)

def main():
    OUTPUT_IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_LABELS_DIR.mkdir(parents=True, exist_ok=True)

    pairs = get_matched_pairs()
    print(f"매칭된 이미지-라벨 쌍: {len(pairs)}개")

    total_generated = 0

    for idx, (img_path, label_path) in enumerate(pairs):
        if idx % 100 == 0:
            print(f"처리 중: {idx}/{len(pairs)}")

        # 원본 이미지/라벨 읽기
        img = cv2.imread(str(img_path))
        if img is None:
            continue

        labels = label_path.read_text().strip().split('\n')
        base_name = img_path.stem

        # 1. 원본 복사
        shutil.copy(img_path, OUTPUT_IMAGES_DIR / img_path.name)
        shutil.copy(label_path, OUTPUT_LABELS_DIR / label_path.name)
        total_generated += 1

        # 2. 밝게
        bright_img = apply_brightness_contrast(img, alpha=1.2, beta=20)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_bright.jpg"), bright_img)
        (OUTPUT_LABELS_DIR / f"{base_name}_bright.txt").write_text('\n'.join(labels))
        total_generated += 1

        # 3. 어둡게
        dark_img = apply_brightness_contrast(img, alpha=0.8, beta=-20)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_dark.jpg"), dark_img)
        (OUTPUT_LABELS_DIR / f"{base_name}_dark.txt").write_text('\n'.join(labels))
        total_generated += 1

        # 4. 좌우 반전
        flipped_img, flipped_labels = apply_horizontal_flip(img, labels)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_flip.jpg"), flipped_img)
        (OUTPUT_LABELS_DIR / f"{base_name}_flip.txt").write_text('\n'.join(flipped_labels))
        total_generated += 1

        # 5. 모션 블러
        blur_img = apply_motion_blur(img, size=7)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_blur.jpg"), blur_img)
        (OUTPUT_LABELS_DIR / f"{base_name}_blur.txt").write_text('\n'.join(labels))
        total_generated += 1

        # 6. 색상 변화
        color_img = apply_color_jitter(img)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_color.jpg"), color_img)
        (OUTPUT_LABELS_DIR / f"{base_name}_color.txt").write_text('\n'.join(labels))
        total_generated += 1

        # 7. 노이즈
        noise_img = apply_gaussian_noise(img, var=15)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_noise.jpg"), noise_img)
        (OUTPUT_LABELS_DIR / f"{base_name}_noise.txt").write_text('\n'.join(labels))
        total_generated += 1

        # 8. 밝게 + 반전
        bright_flipped, bright_flipped_labels = apply_horizontal_flip(bright_img, labels)
        cv2.imwrite(str(OUTPUT_IMAGES_DIR / f"{base_name}_bright_flip.jpg"), bright_flipped)
        (OUTPUT_LABELS_DIR / f"{base_name}_bright_flip.txt").write_text('\n'.join(bright_flipped_labels))
        total_generated += 1

    print(f"\n=== 증강 완료 ===")
    print(f"원본 이미지: {len(pairs)}개")
    print(f"증강 후 총: {total_generated}개 (약 {total_generated / len(pairs):.1f}배)")
    print(f"저장 위치:")
    print(f"  이미지: {OUTPUT_IMAGES_DIR}")
    print(f"  라벨: {OUTPUT_LABELS_DIR}")

if __name__ == '__main__':
    main()
