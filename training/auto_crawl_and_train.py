#!/usr/bin/env python3
"""
자동 크롤링 및 학습 스크립트
1. YouTube에서 바벨 운동 영상 다운로드
2. 프레임 추출
3. 기존 모델로 pseudo-labeling
4. 추가 학습
"""

import subprocess
import os
from pathlib import Path
import shutil
import random

TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / "crawled_data"
FRAMES_DIR = OUTPUT_DIR / "frames"
VIDEOS_DIR = OUTPUT_DIR / "videos"

# 바벨 운동 영상 URL (측면 촬영, 저작권 무료/교육용)
YOUTUBE_URLS = [
    # 스쿼트 측면
    ("https://www.youtube.com/watch?v=ultWZbUMPL8", "squat_side_1"),  # Squat University
    ("https://www.youtube.com/watch?v=bEv6CCg2BC8", "squat_side_2"),  # Alan Thrall
    ("https://www.youtube.com/watch?v=vmNPOjaGrVE", "squat_form_1"),
    # 벤치 프레스
    ("https://www.youtube.com/watch?v=rT7DgCr-3pg", "bench_side_1"),
    ("https://www.youtube.com/watch?v=4Y2ZdHCOXok", "bench_form_1"),
    # 데드리프트
    ("https://www.youtube.com/watch?v=op9kVnSso6Q", "deadlift_side_1"),
    ("https://www.youtube.com/watch?v=r4MzxtBKyNE", "deadlift_form_1"),
    # 오버헤드 프레스
    ("https://www.youtube.com/watch?v=_RlRDWO2jfg", "ohp_side_1"),
]

def setup_dirs():
    """폴더 생성"""
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)
    print(f"출력 폴더: {OUTPUT_DIR}")

def download_video(url: str, name: str) -> Path:
    """YouTube 영상 다운로드"""
    output_path = VIDEOS_DIR / f"{name}.mp4"

    if output_path.exists():
        print(f"  [스킵] 이미 존재: {name}")
        return output_path

    print(f"  다운로드: {name}")
    cmd = [
        "yt-dlp",
        "-f", "bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/best[height<=480][ext=mp4]/best",
        "-o", str(output_path),
        "--no-playlist",
        "--socket-timeout", "30",
        "--retries", "3",
        url
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, timeout=120)
        if output_path.exists():
            print(f"    완료: {output_path.name}")
            return output_path
        else:
            print(f"    실패")
            return None
    except subprocess.TimeoutExpired:
        print(f"    타임아웃")
        return None
    except Exception as e:
        print(f"    에러: {e}")
        return None

def extract_frames(video_path: Path, prefix: str, fps: float = 1.0) -> int:
    """영상에서 프레임 추출"""
    output_pattern = str(FRAMES_DIR / f"{prefix}_%04d.jpg")

    # 이미 추출된 프레임이 있는지 확인
    existing = list(FRAMES_DIR.glob(f"{prefix}_*.jpg"))
    if existing:
        print(f"  [스킵] 이미 추출됨: {len(existing)}개")
        return len(existing)

    print(f"  프레임 추출: {video_path.name} @ {fps}fps")
    cmd = [
        "ffmpeg",
        "-i", str(video_path),
        "-vf", f"fps={fps}",
        "-q:v", "3",
        output_pattern,
        "-y",
        "-loglevel", "error"
    ]

    try:
        subprocess.run(cmd, check=True, timeout=60)
        count = len(list(FRAMES_DIR.glob(f"{prefix}_*.jpg")))
        print(f"    완료: {count}개 프레임")
        return count
    except Exception as e:
        print(f"    에러: {e}")
        return 0

def crawl_all():
    """모든 영상 크롤링"""
    print("\n" + "=" * 50)
    print("YouTube 바벨 운동 영상 크롤링")
    print("=" * 50)

    setup_dirs()
    total_frames = 0

    for url, name in YOUTUBE_URLS:
        print(f"\n[{name}]")
        video = download_video(url, name)
        if video:
            frames = extract_frames(video, name)
            total_frames += frames

    print(f"\n총 추출된 프레임: {total_frames}개")
    print(f"위치: {FRAMES_DIR}")
    return total_frames

def create_pseudo_labels():
    """
    기존 모델로 pseudo-labeling (자동 라벨링)
    현재 학습된 모델로 추출된 프레임에서 바벨 위치 예측
    """
    print("\n" + "=" * 50)
    print("Pseudo-labeling (자동 라벨링)")
    print("=" * 50)

    # 최신 학습된 모델 찾기
    model_paths = [
        TRAINING_DIR / "runs" / "detect" / "barbell_plate_detector" / "weights" / "best.pt",
        TRAINING_DIR / "runs" / "detect" / "barbell_detector_v2" / "weights" / "best.pt",
    ]

    model_path = None
    for p in model_paths:
        if p.exists():
            model_path = p
            break

    if not model_path:
        print("학습된 모델이 없습니다. pseudo-labeling 스킵")
        return False

    print(f"모델: {model_path}")

    try:
        from ultralytics import YOLO
        model = YOLO(str(model_path))

        # 추출된 프레임에서 예측
        frames = list(FRAMES_DIR.glob("*.jpg"))
        if not frames:
            print("추출된 프레임이 없습니다")
            return False

        print(f"프레임 수: {len(frames)}")

        # 라벨 저장 폴더
        labels_dir = OUTPUT_DIR / "labels"
        labels_dir.mkdir(exist_ok=True)

        labeled_count = 0
        for frame in frames:
            results = model(str(frame), verbose=False)

            # YOLO 형식으로 라벨 저장
            label_path = labels_dir / f"{frame.stem}.txt"

            with open(label_path, "w") as f:
                for result in results:
                    if result.boxes is not None:
                        for box in result.boxes:
                            if box.conf >= 0.5:  # 신뢰도 0.5 이상만
                                # YOLO 형식: class cx cy w h (정규화)
                                x1, y1, x2, y2 = box.xyxyn[0].tolist()
                                cx = (x1 + x2) / 2
                                cy = (y1 + y2) / 2
                                w = x2 - x1
                                h = y2 - y1
                                f.write(f"0 {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n")
                                labeled_count += 1

        print(f"자동 라벨링 완료: {labeled_count}개 바운딩 박스")
        return True

    except Exception as e:
        print(f"Pseudo-labeling 에러: {e}")
        return False

def merge_datasets():
    """기존 데이터셋과 크롤링 데이터 병합"""
    print("\n" + "=" * 50)
    print("데이터셋 병합")
    print("=" * 50)

    # 대상 폴더
    plate_dataset = TRAINING_DIR / "barbell_plate_dataset"
    if not plate_dataset.exists():
        print("기존 데이터셋이 없습니다")
        return

    train_images = plate_dataset / "train" / "images"
    train_labels = plate_dataset / "train" / "labels"

    # 크롤링 데이터 복사
    crawled_images = list(FRAMES_DIR.glob("*.jpg"))
    crawled_labels_dir = OUTPUT_DIR / "labels"

    copied = 0
    for img in crawled_images:
        # 이미지 복사
        dst_img = train_images / f"crawled_{img.name}"
        if not dst_img.exists():
            shutil.copy(img, dst_img)

            # 라벨 복사
            label_src = crawled_labels_dir / f"{img.stem}.txt"
            label_dst = train_labels / f"crawled_{img.stem}.txt"
            if label_src.exists():
                shutil.copy(label_src, label_dst)
            else:
                # 빈 라벨 (background)
                label_dst.touch()

            copied += 1

    print(f"복사된 이미지: {copied}개")
    total = len(list(train_images.glob("*.jpg"))) + len(list(train_images.glob("*.png")))
    print(f"총 학습 이미지: {total}개")

def retrain():
    """추가 데이터로 재학습"""
    print("\n" + "=" * 50)
    print("모델 재학습")
    print("=" * 50)

    data_yaml = TRAINING_DIR / "barbell_plate_dataset" / "data.yaml"
    if not data_yaml.exists():
        print("data.yaml 없음")
        return

    try:
        from ultralytics import YOLO

        # 기존 best 모델이 있으면 이어서 학습, 없으면 새로 시작
        best_model = TRAINING_DIR / "runs" / "detect" / "barbell_plate_detector" / "weights" / "best.pt"
        if best_model.exists():
            model = YOLO(str(best_model))
            print("기존 모델 기반 추가 학습")
        else:
            model = YOLO("yolov8n.pt")
            print("새 모델 학습")

        results = model.train(
            data=str(data_yaml),
            epochs=50,  # 추가 학습이므로 적은 에포크
            imgsz=320,
            batch=16,
            name="barbell_plate_detector_v2",
            patience=15,
            device="mps",
            workers=4,
        )

        print("\n재학습 완료!")

        # Export
        print("\n모델 Export...")
        model.export(format="coreml", imgsz=320, half=True, nms=True)
        model.export(format="tflite", imgsz=320, half=True)

        # 앱으로 복사
        runs_dir = TRAINING_DIR / "runs" / "detect" / "barbell_plate_detector_v2" / "weights"

        coreml_src = runs_dir / "best.mlpackage"
        coreml_dst = TRAINING_DIR.parent / "example" / "ios" / "Runner" / "barbell_detector.mlpackage"
        if coreml_src.exists() and coreml_dst.parent.exists():
            if coreml_dst.exists():
                shutil.rmtree(coreml_dst)
            shutil.copytree(coreml_src, coreml_dst)
            print(f"CoreML 복사: {coreml_dst}")

        tflite_src = runs_dir / "best_float16.tflite"
        tflite_dst = TRAINING_DIR.parent / "barbell_tracking" / "assets" / "ml" / "barbell_detector.tflite"
        if tflite_src.exists() and tflite_dst.parent.exists():
            shutil.copy(tflite_src, tflite_dst)
            print(f"TFLite 복사: {tflite_dst}")

    except Exception as e:
        print(f"재학습 에러: {e}")

def main():
    print("=" * 60)
    print("자동 크롤링 및 학습 시작")
    print("=" * 60)

    # 1. 크롤링
    crawl_all()

    # 2. Pseudo-labeling
    create_pseudo_labels()

    # 3. 데이터셋 병합
    merge_datasets()

    # 4. 재학습
    retrain()

    print("\n" + "=" * 60)
    print("완료!")
    print("=" * 60)

if __name__ == "__main__":
    main()
