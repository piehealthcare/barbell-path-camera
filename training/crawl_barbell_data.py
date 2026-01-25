#!/usr/bin/env python3
"""
바벨 운동 데이터 대량 크롤링 스크립트
- YouTube에서 바벨 운동 영상 다운로드
- 프레임 추출 (측면 뷰 위주)
- 다양한 운동 종류 포함

사용법:
    python3 crawl_barbell_data.py
"""

import subprocess
import os
from pathlib import Path
import random

TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / "crawled_data_v2"
FRAMES_DIR = OUTPUT_DIR / "frames"
VIDEOS_DIR = OUTPUT_DIR / "videos"

# 바벨 운동 영상 URL 목록 (측면/45도 촬영 위주)
YOUTUBE_URLS = [
    # ============= 스쿼트 (Squat) =============
    ("https://www.youtube.com/watch?v=ultWZbUMPL8", "squat_university_1"),
    ("https://www.youtube.com/watch?v=bEv6CCg2BC8", "squat_alan_thrall"),
    ("https://www.youtube.com/watch?v=vmNPOjaGrVE", "squat_form_check"),
    ("https://www.youtube.com/watch?v=Dy28eq2PjcM", "squat_athleanx"),
    ("https://www.youtube.com/watch?v=gcNh17Ckjgg", "squat_side_view"),
    ("https://www.youtube.com/watch?v=1oed-UmAxFs", "squat_proper_form"),
    ("https://www.youtube.com/watch?v=bs_Ej32IYgo", "squat_depth"),
    ("https://www.youtube.com/watch?v=nhoikoUEI8U", "squat_tutorial"),
    ("https://www.youtube.com/watch?v=QmZAiBqPvZw", "squat_mistakes"),
    ("https://www.youtube.com/watch?v=Uv_DKDl7EjA", "squat_powerlifting"),

    # ============= 벤치 프레스 (Bench Press) =============
    ("https://www.youtube.com/watch?v=rT7DgCr-3pg", "bench_side_1"),
    ("https://www.youtube.com/watch?v=4Y2ZdHCOXok", "bench_form_1"),
    ("https://www.youtube.com/watch?v=gRVjAtPip0Y", "bench_tutorial"),
    ("https://www.youtube.com/watch?v=vthMCtgVtFw", "bench_proper_form"),
    ("https://www.youtube.com/watch?v=BYKScL2sgCs", "bench_athleanx"),
    ("https://www.youtube.com/watch?v=vcBig73ojpE", "bench_powerlifting"),
    ("https://www.youtube.com/watch?v=esQi683XR44", "bench_mistakes"),
    ("https://www.youtube.com/watch?v=wKhI-O4HI8M", "bench_side_view"),

    # ============= 데드리프트 (Deadlift) =============
    ("https://www.youtube.com/watch?v=op9kVnSso6Q", "deadlift_side_1"),
    ("https://www.youtube.com/watch?v=r4MzxtBKyNE", "deadlift_form_1"),
    ("https://www.youtube.com/watch?v=hCDzSR6bW10", "deadlift_tutorial"),
    ("https://www.youtube.com/watch?v=ytGaGIn3SjE", "deadlift_proper"),
    ("https://www.youtube.com/watch?v=1ZXobu7JvvE", "deadlift_conventional"),
    ("https://www.youtube.com/watch?v=wYREQkVtvEc", "deadlift_sumo"),
    ("https://www.youtube.com/watch?v=NYN3UGCYisk", "deadlift_mistakes"),
    ("https://www.youtube.com/watch?v=VL5Ab0T07e4", "deadlift_powerlifting"),

    # ============= 오버헤드 프레스 (OHP) =============
    ("https://www.youtube.com/watch?v=_RlRDWO2jfg", "ohp_side_1"),
    ("https://www.youtube.com/watch?v=2yjwXTZQDDI", "ohp_tutorial"),
    ("https://www.youtube.com/watch?v=QAQ64hK4Xxs", "ohp_proper_form"),
    ("https://www.youtube.com/watch?v=wol7Hko8RhY", "ohp_strict"),
    ("https://www.youtube.com/watch?v=F3QY5vMz_6I", "ohp_standing"),

    # ============= 바벨 로우 (Barbell Row) =============
    ("https://www.youtube.com/watch?v=kBWAon7ItDw", "row_bent_over"),
    ("https://www.youtube.com/watch?v=9efgcAjQe7E", "row_pendlay"),
    ("https://www.youtube.com/watch?v=FWJR5Ve8bnQ", "row_tutorial"),
    ("https://www.youtube.com/watch?v=T3N-TO4reLQ", "row_proper_form"),

    # ============= 클린 & 저크 (Clean & Jerk) =============
    ("https://www.youtube.com/watch?v=EKRiW9Yt3Ps", "clean_tutorial"),
    ("https://www.youtube.com/watch?v=KrEEBrxv7IY", "clean_slow_motion"),
    ("https://www.youtube.com/watch?v=_AjcJEBG1_0", "clean_side_view"),
    ("https://www.youtube.com/watch?v=Um3kY5qHfI0", "jerk_tutorial"),

    # ============= 스내치 (Snatch) =============
    ("https://www.youtube.com/watch?v=9xQp2sldyts", "snatch_tutorial"),
    ("https://www.youtube.com/watch?v=RZogNe2elLc", "snatch_slow_motion"),
    ("https://www.youtube.com/watch?v=F2kXSmLgd3M", "snatch_side"),

    # ============= 파워리프팅 대회 (Competition) =============
    ("https://www.youtube.com/watch?v=_S4N8Rq9BWI", "powerlifting_comp_1"),
    ("https://www.youtube.com/watch?v=8dhvlPMZqPw", "powerlifting_squat"),
    ("https://www.youtube.com/watch?v=HQC-ZNZJZpI", "weightlifting_comp"),

    # ============= 헬스장 일반 (Gym General) =============
    ("https://www.youtube.com/watch?v=KMjSN4d9E0Y", "gym_workout_1"),
    ("https://www.youtube.com/watch?v=R0mMyV5OtcM", "gym_barbell_workout"),
]

def setup_dirs():
    """폴더 생성"""
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)
    print(f"출력 폴더: {OUTPUT_DIR}")

def check_tools():
    """필요한 도구 확인"""
    try:
        subprocess.run(["yt-dlp", "--version"], capture_output=True, check=True)
    except:
        print("yt-dlp가 설치되지 않았습니다. 설치 중...")
        subprocess.run(["brew", "install", "yt-dlp"])

    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
    except:
        print("ffmpeg가 설치되지 않았습니다. 설치 중...")
        subprocess.run(["brew", "install", "ffmpeg"])

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
        "--max-filesize", "100M",  # 최대 100MB
        url
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, timeout=180)
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

def extract_frames(video_path: Path, prefix: str, fps: float = 2.0) -> int:
    """영상에서 프레임 추출 (2fps = 초당 2프레임)"""
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
        "-vf", f"fps={fps},scale=640:-1",  # 640px 너비로 리사이즈
        "-q:v", "3",  # 품질 (1-31, 낮을수록 좋음)
        output_pattern,
        "-y",
        "-loglevel", "error"
    ]

    try:
        subprocess.run(cmd, check=True, timeout=120)
        count = len(list(FRAMES_DIR.glob(f"{prefix}_*.jpg")))
        print(f"    완료: {count}개 프레임")
        return count
    except Exception as e:
        print(f"    에러: {e}")
        return 0

def crawl_all():
    """모든 영상 크롤링"""
    print("\n" + "=" * 60)
    print("🏋️ 바벨 운동 데이터 대량 크롤링")
    print("=" * 60)

    check_tools()
    setup_dirs()

    total_frames = 0
    successful = 0
    failed = 0

    for i, (url, name) in enumerate(YOUTUBE_URLS):
        print(f"\n[{i+1}/{len(YOUTUBE_URLS)}] {name}")
        video = download_video(url, name)
        if video:
            frames = extract_frames(video, name)
            total_frames += frames
            successful += 1
        else:
            failed += 1

    print(f"\n" + "=" * 60)
    print(f"크롤링 완료!")
    print(f"  성공: {successful}개 영상")
    print(f"  실패: {failed}개 영상")
    print(f"  총 프레임: {total_frames}개")
    print(f"  위치: {FRAMES_DIR}")
    print("=" * 60)

    return total_frames

def copy_to_labeling():
    """추출된 프레임을 라벨링 폴더로 복사"""
    import shutil

    labeling_dir = TRAINING_DIR / "labeling_images"
    labeling_dir.mkdir(exist_ok=True)

    frames = list(FRAMES_DIR.glob("*.jpg"))
    copied = 0

    for f in frames:
        dst = labeling_dir / f"crawled_v2_{f.name}"
        if not dst.exists():
            shutil.copy(f, dst)
            copied += 1

    print(f"\n라벨링 폴더로 {copied}개 이미지 복사됨")
    print(f"위치: {labeling_dir}")

def main():
    total = crawl_all()

    if total > 0:
        print("\n라벨링 폴더로 복사하시겠습니까? (y/n)")
        response = input().strip().lower()
        if response == 'y':
            copy_to_labeling()

    print("\n완료!")

if __name__ == "__main__":
    main()
