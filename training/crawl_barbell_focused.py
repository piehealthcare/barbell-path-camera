#!/usr/bin/env python3
"""바벨 운동 포커스 크롤링 - 클로즈업/측면 뷰 위주"""
import subprocess
from pathlib import Path

TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / "crawled_data_v3"
FRAMES_DIR = OUTPUT_DIR / "frames"
VIDEOS_DIR = OUTPUT_DIR / "videos"

# 바벨 클로즈업/측면 뷰 영상 (운동 폼 체크용)
BARBELL_FOCUSED_URLS = [
    # ============= 바벨 클로즈업 폼체크 영상 =============
    ("https://www.youtube.com/watch?v=bWRTHOMq-n8", "squat_side_closeup_1"),
    ("https://www.youtube.com/watch?v=Dy28eq2PjcM", "squat_form_athlean"),
    ("https://www.youtube.com/watch?v=nEQQle9-0NA", "squat_bar_path"),
    ("https://www.youtube.com/watch?v=C_VtOYc6j5c", "squat_low_bar"),
    ("https://www.youtube.com/watch?v=SW_C1A-rejs", "squat_high_bar"),
    
    # ============= 데드리프트 측면 =============
    ("https://www.youtube.com/watch?v=wYREQkVtvEc", "deadlift_side_form"),
    ("https://www.youtube.com/watch?v=XxWcirHIwVo", "deadlift_bar_path"),
    ("https://www.youtube.com/watch?v=MBbyAqvTNkU", "deadlift_closeup"),
    
    # ============= 벤치프레스 측면 =============
    ("https://www.youtube.com/watch?v=_QnwAoesJvQ", "bench_side_form"),
    ("https://www.youtube.com/watch?v=Bvn2dBFR3EE", "bench_bar_path"),
    
    # ============= 오버헤드프레스 =============
    ("https://www.youtube.com/watch?v=_RlRDWO2jfg", "ohp_side_form"),
    ("https://www.youtube.com/watch?v=wol7Hko8RhY", "ohp_strict_press"),
    
    # ============= 역도 (클린/저크/스내치) =============
    ("https://www.youtube.com/watch?v=V-hKvAoXuLo", "clean_side_slow"),
    ("https://www.youtube.com/watch?v=_AjcJEBG1_0", "clean_jerk_side"),
    ("https://www.youtube.com/watch?v=wMZsGEoI6hc", "snatch_side_slow"),
    
    # ============= 바벨로우 =============
    ("https://www.youtube.com/watch?v=kBWAon7ItDw", "row_bent_over_form"),
    ("https://www.youtube.com/watch?v=axoeDmW0oAY", "row_pendlay_side"),
    
    # ============= 파워리프팅 대회 (측면 앵글) =============
    ("https://www.youtube.com/watch?v=t1nH8JQYLcY", "powerlifting_squat_side"),
    ("https://www.youtube.com/watch?v=dO3B1p9NVVg", "powerlifting_deadlift_side"),
    ("https://www.youtube.com/watch?v=Dn_lNlwWKqU", "weightlifting_competition"),
    
    # ============= 폼 분석 영상 =============
    ("https://www.youtube.com/watch?v=vmNPOjaGrVE", "form_check_squat"),
    ("https://www.youtube.com/watch?v=jEy_czb3RKA", "form_analysis_deadlift"),
    ("https://www.youtube.com/watch?v=oiDczs9j75E", "slow_motion_lifts"),
]

def setup():
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

def download_video(url, name):
    output = VIDEOS_DIR / f"{name}.mp4"
    if output.exists():
        print(f"  [스킵] {name}")
        return output
    
    print(f"  다운로드: {name}")
    cmd = [
        "yt-dlp", "-f", "bestvideo[height<=480]+bestaudio/best[height<=480]/best",
        "-o", str(output), "--no-playlist", "--socket-timeout", "30",
        "--retries", "3", "--max-filesize", "100M", url
    ]
    try:
        subprocess.run(cmd, capture_output=True, timeout=180)
        return output if output.exists() else None
    except:
        return None

def extract_frames(video, prefix, fps=2):
    pattern = str(FRAMES_DIR / f"{prefix}_%04d.jpg")
    existing = list(FRAMES_DIR.glob(f"{prefix}_*.jpg"))
    if existing:
        return len(existing)
    
    cmd = ["ffmpeg", "-i", str(video), "-vf", f"fps={fps},scale=640:-1",
           "-q:v", "3", pattern, "-y", "-loglevel", "error"]
    try:
        subprocess.run(cmd, timeout=120)
        return len(list(FRAMES_DIR.glob(f"{prefix}_*.jpg")))
    except:
        return 0

def main():
    print("=" * 60)
    print("바벨 운동 포커스 크롤링 (측면/클로즈업)")
    print("=" * 60)
    
    setup()
    total = 0
    
    for i, (url, name) in enumerate(BARBELL_FOCUSED_URLS):
        print(f"\n[{i+1}/{len(BARBELL_FOCUSED_URLS)}] {name}")
        video = download_video(url, name)
        if video:
            frames = extract_frames(video, name)
            total += frames
            print(f"    프레임: {frames}개")
    
    print(f"\n완료! 총 {total}개 프레임")
    print(f"위치: {FRAMES_DIR}")

if __name__ == "__main__":
    main()
