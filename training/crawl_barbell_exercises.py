#!/usr/bin/env python3
"""
바벨 운동 영상 크롤링 - 실제 운동 수행 영상
데드리프트, 벤치프레스, 스쿼트 - 옆에서 촬영
"""

import subprocess
from pathlib import Path

OUTPUT_DIR = Path(__file__).parent / "crawled_barbell"
VIDEOS_DIR = OUTPUT_DIR / "videos"
FRAMES_DIR = Path(__file__).parent / "labeling_images"

# 실제 운동 수행 영상 위주 검색어
SEARCH_QUERIES = [
    # 파워리프팅 대회 영상 (실제 수행)
    "powerlifting competition deadlift side view",
    "powerlifting meet squat side angle",
    "IPF powerlifting deadlift",
    "USAPL powerlifting squat",
    "powerlifting bench press competition",

    # 1RM / PR 영상 (실제 수행)
    "deadlift PR side view",
    "squat max attempt side",
    "bench press 1RM side view",
    "heavy deadlift side angle",
    "heavy squat side view gym",

    # 세트 운동 영상
    "deadlift working sets gym",
    "squat 5x5 side view",
    "bench press sets reps side",
    "barbell row side view gym",
    "overhead press side angle",

    # 홈짐/체육관 영상
    "home gym deadlift side",
    "garage gym squat side view",
    "gym deadlift form side",
    "commercial gym squat rack side",
]

def download_videos():
    """yt-dlp로 영상 다운로드"""
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

    downloaded = 0
    target = 15

    for query in SEARCH_QUERIES:
        if downloaded >= target:
            break

        print(f"\n🔍 검색: {query}")

        try:
            result = subprocess.run([
                "yt-dlp",
                f"ytsearch2:{query}",  # 검색당 2개
                "--format", "best[height<=720]",
                "--output", str(VIDEOS_DIR / f"barbell_%(title).25s_%(id)s.%(ext)s"),
                "--max-downloads", "2",
                "--match-filter", "duration > 10 & duration < 300",  # 10초~5분
                "--no-playlist",
                "--quiet",
                "--no-warnings",
            ], capture_output=True, text=True, timeout=90)

            new_count = len(list(VIDEOS_DIR.glob("*")))
            if new_count > downloaded:
                added = new_count - downloaded
                downloaded = new_count
                print(f"  ✓ {added}개 다운로드")

        except subprocess.TimeoutExpired:
            print(f"  ⏱ 타임아웃")
        except Exception as e:
            print(f"  ✗ 에러: {e}")

    print(f"\n총 {downloaded}개 영상 다운로드")
    return downloaded

def extract_frames():
    """영상에서 프레임 추출 - 운동 구간 위주"""
    import cv2

    videos = list(VIDEOS_DIR.glob("*.mp4")) + list(VIDEOS_DIR.glob("*.webm")) + list(VIDEOS_DIR.glob("*.mkv"))
    print(f"\n🎬 {len(videos)}개 영상에서 프레임 추출")

    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    total_frames = 0

    for video_path in videos:
        video_name = video_path.stem[:35].replace(" ", "_").replace("/", "_")

        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            print(f"  ✗ 열기 실패: {video_path.name}")
            continue

        fps = cap.get(cv2.CAP_PROP_FPS)
        total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        duration = total / fps if fps > 0 else 0

        # 3fps로 추출 (0.33초마다)
        interval = max(1, int(fps / 3))

        frame_count = 0
        saved = 0

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            if frame_count % interval == 0:
                output_name = f"barbell_{video_name}_{frame_count:05d}.jpg"
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
        print(f"  ✓ {video_path.name[:40]}... → {saved}프레임")

    print(f"\n총 {total_frames}개 프레임 추출")
    return total_frames

def main():
    print("=" * 50)
    print("바벨 운동 영상 크롤링")
    print("(데드리프트, 스쿼트, 벤치프레스 실제 수행)")
    print("=" * 50)

    download_videos()
    extract_frames()

    print("\n✅ 완료!")
    print(f"   프레임 저장: {FRAMES_DIR}")

if __name__ == "__main__":
    main()
