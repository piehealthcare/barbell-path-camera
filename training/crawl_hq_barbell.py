#!/usr/bin/env python3
"""
고화질 바벨 운동 영상 크롤링
실제 운동 수행 영상만 (CG/튜토리얼 제외)
"""

import subprocess
from pathlib import Path

OUTPUT_DIR = Path(__file__).parent / "crawled_hq"
VIDEOS_DIR = OUTPUT_DIR / "videos"
FRAMES_DIR = Path(__file__).parent / "labeling_images"

# 실제 운동 영상 검색어
SEARCH_QUERIES = [
    # 데드리프트 실제 수행
    "deadlift gym POV",
    "deadlift set side view",
    "conventional deadlift gym",
    "sumo deadlift training",

    # 벤치프레스 실제 수행
    "bench press gym training",
    "bench press side angle gym",
    "paused bench press",

    # 스쿼트 실제 수행
    "squat training side view",
    "back squat gym",
    "low bar squat training",
    "high bar squat gym",

    # 파워리프팅 실제 영상
    "powerlifting training session",
    "powerlifting gym footage",
    "strength training compound lifts",
]

def download_videos():
    """고화질 영상 다운로드"""
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

    # 기존 영상 삭제
    for f in VIDEOS_DIR.glob("*"):
        f.unlink()

    downloaded = 0
    target = 15

    for query in SEARCH_QUERIES:
        if downloaded >= target:
            break

        print(f"\n🔍 검색: {query}")

        try:
            result = subprocess.run([
                "yt-dlp",
                f"ytsearch2:{query}",
                "--format", "bestvideo[height>=720][height<=1080]+bestaudio/best[height>=720]",
                "--output", str(VIDEOS_DIR / f"hq_%(title).25s_%(id)s.%(ext)s"),
                "--max-downloads", "2",
                "--match-filter", "duration > 30 & duration < 600",  # 30초~10분
                "--no-playlist",
                "--quiet",
                "--no-warnings",
                "--merge-output-format", "mp4",
            ], capture_output=True, text=True, timeout=180)

            new_count = len(list(VIDEOS_DIR.glob("*")))
            if new_count > downloaded:
                added = new_count - downloaded
                downloaded = new_count
                print(f"  ✓ {added}개 다운로드 (720p+)")

        except subprocess.TimeoutExpired:
            print(f"  ⏱ 타임아웃")
        except Exception as e:
            print(f"  ✗ 에러: {e}")

    print(f"\n총 {downloaded}개 영상 다운로드")
    return downloaded

def extract_frames():
    """고화질 프레임 추출"""
    import cv2

    videos = list(VIDEOS_DIR.glob("*.mp4")) + list(VIDEOS_DIR.glob("*.webm")) + list(VIDEOS_DIR.glob("*.mkv"))
    print(f"\n🎬 {len(videos)}개 영상에서 프레임 추출")

    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    total_frames = 0

    for video_path in videos:
        video_name = video_path.stem[:30].replace(" ", "_").replace("/", "_")

        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            print(f"  ✗ 열기 실패: {video_path.name}")
            continue

        fps = cap.get(cv2.CAP_PROP_FPS)
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        print(f"  📹 {video_path.name[:40]}: {width}x{height}")

        # 3fps로 추출
        interval = max(1, int(fps / 3))

        frame_count = 0
        saved = 0

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            if frame_count % interval == 0:
                output_name = f"hq_{video_name}_{frame_count:05d}.jpg"
                output_path = FRAMES_DIR / output_name

                # 1280 너비로 리사이즈 (비율 유지)
                h, w = frame.shape[:2]
                if w > 1280:
                    scale = 1280 / w
                    frame = cv2.resize(frame, (1280, int(h * scale)))

                cv2.imwrite(str(output_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
                saved += 1

            frame_count += 1

        cap.release()
        total_frames += saved
        print(f"     → {saved}프레임 추출")

    print(f"\n총 {total_frames}개 프레임 추출")
    return total_frames

def main():
    print("=" * 50)
    print("고화질 바벨 운동 영상 크롤링")
    print("(720p 이상, 실제 운동 영상)")
    print("=" * 50)

    download_videos()
    extract_frames()

    # 결과 확인
    images = list(FRAMES_DIR.glob("hq_*.jpg"))
    if images:
        import cv2
        sample = cv2.imread(str(images[0]))
        if sample is not None:
            h, w = sample.shape[:2]
            print(f"\n📊 결과:")
            print(f"   총 프레임: {len(images)}개")
            print(f"   이미지 크기: {w}x{h}")

    print("\n✅ 완료!")

if __name__ == "__main__":
    main()
