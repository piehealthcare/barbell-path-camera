#!/usr/bin/env python3
"""
바벨 운동 쇼츠 크롤링 - 실제 운동 영상만
"""

import subprocess
from pathlib import Path

OUTPUT_DIR = Path(__file__).parent / "crawled_shorts"
VIDEOS_DIR = OUTPUT_DIR / "videos"
FRAMES_DIR = Path(__file__).parent / "labeling_images"

# 쇼츠 검색어 - 실제 운동 수행
SEARCH_QUERIES = [
    # 데드리프트 쇼츠
    "deadlift shorts gym",
    "deadlift PR shorts",
    "heavy deadlift shorts",
    "데드리프트 쇼츠",
    "sumo deadlift shorts",

    # 벤치프레스 쇼츠
    "bench press shorts gym",
    "bench press PR shorts",
    "heavy bench shorts",
    "벤치프레스 쇼츠",

    # 스쿼트 쇼츠
    "squat shorts gym",
    "squat PR shorts",
    "heavy squat shorts",
    "스쿼트 쇼츠",
    "barbell squat shorts",

    # 파워리프팅 쇼츠
    "powerlifting shorts",
    "powerlifting gym shorts",
    "파워리프팅 쇼츠",
]

def download_shorts():
    """yt-dlp로 쇼츠 다운로드"""
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

    downloaded = 0
    target = 25

    for query in SEARCH_QUERIES:
        if downloaded >= target:
            break

        print(f"\n🔍 검색: {query}")

        try:
            result = subprocess.run([
                "yt-dlp",
                f"ytsearch5:{query}",
                "--format", "best[height<=720]",
                "--output", str(VIDEOS_DIR / f"shorts_%(title).20s_%(id)s.%(ext)s"),
                "--max-downloads", "3",
                "--match-filter", "duration < 65",  # 65초 미만 (쇼츠)
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

    print(f"\n총 {downloaded}개 쇼츠 다운로드")
    return downloaded

def extract_frames():
    """쇼츠에서 프레임 추출"""
    import cv2

    videos = list(VIDEOS_DIR.glob("*.mp4")) + list(VIDEOS_DIR.glob("*.webm")) + list(VIDEOS_DIR.glob("*.mkv"))
    print(f"\n🎬 {len(videos)}개 쇼츠에서 프레임 추출")

    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    total_frames = 0

    for video_path in videos:
        video_name = video_path.stem[:30].replace(" ", "_").replace("/", "_")

        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            continue

        fps = cap.get(cv2.CAP_PROP_FPS)

        # 5fps로 추출
        interval = max(1, int(fps / 5))

        frame_count = 0
        saved = 0

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            if frame_count % interval == 0:
                output_name = f"shorts_{video_name}_{frame_count:04d}.jpg"
                output_path = FRAMES_DIR / output_name

                h, w = frame.shape[:2]
                if w > 1280:
                    scale = 1280 / w
                    frame = cv2.resize(frame, (1280, int(h * scale)))

                cv2.imwrite(str(output_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
                saved += 1

            frame_count += 1

        cap.release()
        total_frames += saved
        print(f"  ✓ {video_path.name[:35]}... → {saved}프레임")

    print(f"\n총 {total_frames}개 프레임 추출")
    return total_frames

def main():
    print("=" * 50)
    print("바벨 운동 쇼츠 크롤링")
    print("(데드리프트, 벤치프레스, 스쿼트)")
    print("=" * 50)

    download_shorts()
    extract_frames()

    print("\n✅ 완료!")

if __name__ == "__main__":
    main()
