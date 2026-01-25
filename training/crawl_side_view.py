#!/usr/bin/env python3
"""
바벨 운동 영상 크롤링 - 옆에서 촬영된 실제 운동 영상
데드리프트, 벤치프레스, 스쿼트 위주
"""

import subprocess
import sys
from pathlib import Path
import random

# 검색어 목록 - 옆에서 촬영된 실제 운동 영상
SEARCH_QUERIES = [
    # 데드리프트 사이드뷰
    "deadlift side view form check",
    "deadlift side angle technique",
    "conventional deadlift side view",
    "sumo deadlift side angle",
    "deadlift bar path side view",

    # 벤치프레스 사이드뷰
    "bench press side view form",
    "bench press side angle technique",
    "powerlifting bench press side view",
    "competition bench press side angle",

    # 스쿼트 사이드뷰
    "squat side view form check",
    "barbell squat side angle",
    "low bar squat side view",
    "high bar squat side view",
    "powerlifting squat side angle",

    # 파워리프팅 대회 (실제 영상)
    "powerlifting meet deadlift",
    "powerlifting competition squat",
    "powerlifting competition bench",
    "IPF worlds deadlift",
    "USAPL nationals squat",

    # 폼체크 영상 (실제 운동)
    "squat form check reddit",
    "deadlift form check gym",
    "bench press form check powerlifting",
]

OUTPUT_DIR = Path(__file__).parent / "crawled_side_view"
VIDEOS_DIR = OUTPUT_DIR / "videos"
FRAMES_DIR = Path(__file__).parent / "labeling_images"

def download_videos():
    """yt-dlp로 영상 다운로드"""
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

    # 검색어 섞기
    queries = SEARCH_QUERIES.copy()
    random.shuffle(queries)

    downloaded = 0
    target = 20  # 목표 영상 수

    for query in queries:
        if downloaded >= target:
            break

        print(f"\n🔍 검색: {query}")

        try:
            result = subprocess.run([
                "yt-dlp",
                f"ytsearch3:{query}",  # 검색어당 3개
                "--format", "best[height<=720]",
                "--output", str(VIDEOS_DIR / f"side_%(title).30s_%(id)s.%(ext)s"),
                "--max-downloads", "3",
                "--match-filter", "duration < 600",  # 10분 미만
                "--no-playlist",
                "--quiet",
                "--no-warnings",
            ], capture_output=True, text=True, timeout=120)

            # 다운로드된 파일 수 확인
            new_videos = len(list(VIDEOS_DIR.glob("*.mp4"))) + len(list(VIDEOS_DIR.glob("*.webm")))
            if new_videos > downloaded:
                added = new_videos - downloaded
                downloaded = new_videos
                print(f"  ✓ {added}개 다운로드 (총 {downloaded}개)")

        except subprocess.TimeoutExpired:
            print(f"  ⏱ 타임아웃")
        except Exception as e:
            print(f"  ✗ 에러: {e}")

    print(f"\n총 {downloaded}개 영상 다운로드 완료")
    return downloaded

def extract_frames():
    """영상에서 프레임 추출"""
    import cv2

    videos = list(VIDEOS_DIR.glob("*.mp4")) + list(VIDEOS_DIR.glob("*.webm")) + list(VIDEOS_DIR.glob("*.mkv"))
    print(f"\n🎬 {len(videos)}개 영상에서 프레임 추출")

    total_frames = 0

    for video_path in videos:
        video_name = video_path.stem[:40].replace(" ", "_")

        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            print(f"  ✗ 열기 실패: {video_path.name}")
            continue

        fps = cap.get(cv2.CAP_PROP_FPS)
        total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

        # 2fps로 추출 (0.5초마다)
        interval = max(1, int(fps / 2))

        frame_count = 0
        saved = 0

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            if frame_count % interval == 0:
                # 프레임 저장
                output_name = f"side_{video_name}_{frame_count:05d}.jpg"
                output_path = FRAMES_DIR / output_name

                # 리사이즈 (너비 1280 기준)
                h, w = frame.shape[:2]
                if w > 1280:
                    scale = 1280 / w
                    frame = cv2.resize(frame, (1280, int(h * scale)))

                cv2.imwrite(str(output_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
                saved += 1

            frame_count += 1

        cap.release()
        total_frames += saved
        print(f"  ✓ {video_path.name[:30]}... → {saved}프레임")

    print(f"\n총 {total_frames}개 프레임 추출 완료")
    return total_frames

def main():
    print("=" * 50)
    print("바벨 운동 영상 크롤링 (옆에서 촬영, 실제 운동)")
    print("=" * 50)

    # 1. 영상 다운로드
    download_videos()

    # 2. 프레임 추출
    extract_frames()

    print("\n✅ 완료!")
    print(f"   프레임 저장 위치: {FRAMES_DIR}")

if __name__ == "__main__":
    main()
