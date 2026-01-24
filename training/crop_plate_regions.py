#!/usr/bin/env python3
"""
기존 바벨 이미지에서 플레이트 영역만 crop하여
바벨 끝단 감지용 데이터셋 생성
"""

import os
from pathlib import Path
from PIL import Image
import shutil

TRAINING_DIR = Path(__file__).parent
ORIGINAL_DATASET = TRAINING_DIR / "barbell_dataset"
NEW_DATASET = TRAINING_DIR / "barbell_plate_dataset"

def create_dataset_structure():
    """새 데이터셋 폴더 구조 생성"""
    for split in ["train", "valid", "test"]:
        (NEW_DATASET / split / "images").mkdir(parents=True, exist_ok=True)
        (NEW_DATASET / split / "labels").mkdir(parents=True, exist_ok=True)

    # data.yaml 생성
    data_yaml = """names:
- barbell_plate_side
nc: 1
train: train/images
val: valid/images
test: test/images
"""
    (NEW_DATASET / "data.yaml").write_text(data_yaml)
    print("데이터셋 구조 생성 완료")

def process_images_with_crop():
    """
    기존 바벨 이미지에서 플레이트 영역 추출
    - 바벨 bounding box의 양 끝 20% 영역을 플레이트로 가정
    """
    for split in ["train", "valid", "test"]:
        images_dir = ORIGINAL_DATASET / split / "images"
        labels_dir = ORIGINAL_DATASET / split / "labels"

        if not images_dir.exists():
            continue

        print(f"\n=== Processing {split} ===")

        for img_path in images_dir.glob("*"):
            if img_path.suffix.lower() not in [".jpg", ".jpeg", ".png"]:
                continue

            label_path = labels_dir / f"{img_path.stem}.txt"

            if not label_path.exists():
                # Background 이미지 - 그대로 복사
                shutil.copy(img_path, NEW_DATASET / split / "images" / img_path.name)
                # 빈 레이블 파일
                (NEW_DATASET / split / "labels" / f"{img_path.stem}.txt").touch()
                continue

            # 이미지 로드
            try:
                img = Image.open(img_path)
                img_w, img_h = img.size
            except Exception as e:
                print(f"  이미지 로드 실패: {img_path.name} - {e}")
                continue

            # 레이블 파싱
            labels = label_path.read_text().strip().split("\n")
            new_labels = []

            for label in labels:
                if not label.strip():
                    continue

                parts = label.split()
                if len(parts) < 5:
                    continue

                # YOLO 형식: class_id, cx, cy, w, h (정규화)
                class_id = 0  # barbell_plate_side
                cx, cy, w, h = map(float, parts[1:5])

                # 바벨의 좌우 끝 영역을 플레이트로 추출
                # 바벨 bounding box의 좌우 25% 영역
                plate_w = w * 0.25

                # 왼쪽 플레이트
                left_cx = cx - w/2 + plate_w/2
                left_cy = cy
                new_labels.append(f"{class_id} {left_cx:.6f} {left_cy:.6f} {plate_w:.6f} {h:.6f}")

                # 오른쪽 플레이트
                right_cx = cx + w/2 - plate_w/2
                right_cy = cy
                new_labels.append(f"{class_id} {right_cx:.6f} {right_cy:.6f} {plate_w:.6f} {h:.6f}")

            # 이미지 복사
            shutil.copy(img_path, NEW_DATASET / split / "images" / img_path.name)

            # 새 레이블 저장
            (NEW_DATASET / split / "labels" / f"{img_path.stem}.txt").write_text("\n".join(new_labels))

        # 이미지 수 출력
        img_count = len(list((NEW_DATASET / split / "images").glob("*")))
        print(f"  {split}: {img_count} images")

def main():
    print("=" * 50)
    print("바벨 플레이트 데이터셋 생성")
    print("=" * 50)

    create_dataset_structure()
    process_images_with_crop()

    print("\n" + "=" * 50)
    print(f"데이터셋 생성 완료: {NEW_DATASET}")
    print("=" * 50)
    print("\n다음 명령어로 학습:")
    print("python3 train_plate_detector.py")

if __name__ == "__main__":
    main()
