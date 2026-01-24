#!/usr/bin/env python3
"""
온라인 바벨 운동 영상에서 프레임 추출

사용법:
1. YouTube 등에서 바벨 운동 영상 URL 수집
2. 이 스크립트 실행
3. 추출된 프레임을 Roboflow에서 라벨링
"""

import os
import subprocess
from pathlib import Path

TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / "extracted_frames"

# 바벨 운동 영상 추천 키워드
SEARCH_KEYWORDS = """
=== YouTube 검색 키워드 (측면 촬영 영상 권장) ===

스쿼트:
- "barbell squat side view"
- "squat form check side angle"
- "barbell squat technique side view"

벤치 프레스:
- "bench press side view"
- "barbell bench press form"

데드리프트:
- "deadlift side view"
- "barbell deadlift technique"

오버헤드 프레스:
- "overhead press side view"
- "barbell press technique"

권장 채널:
- Squat University
- Jeff Nippard
- Alan Thrall
- Calgary Barbell
- Juggernaut Training Systems

⚠️ 저작권 주의: 개인 학습/연구 목적으로만 사용
"""

def check_dependencies():
    """의존성 확인"""
    try:
        subprocess.run(["yt-dlp", "--version"], capture_output=True, check=True)
        print("✓ yt-dlp 설치됨")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("✗ yt-dlp 필요: brew install yt-dlp 또는 pip install yt-dlp")
        return False

    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
        print("✓ ffmpeg 설치됨")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("✗ ffmpeg 필요: brew install ffmpeg")
        return False

    return True

def download_video(url: str, output_name: str) -> Path:
    """YouTube 영상 다운로드"""
    output_path = OUTPUT_DIR / "videos" / f"{output_name}.mp4"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if output_path.exists():
        print(f"  이미 다운로드됨: {output_name}")
        return output_path

    print(f"  다운로드 중: {url}")
    cmd = [
        "yt-dlp",
        "-f", "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]",
        "-o", str(output_path),
        "--no-playlist",
        url
    ]

    try:
        subprocess.run(cmd, check=True, capture_output=True)
        print(f"  완료: {output_path}")
        return output_path
    except subprocess.CalledProcessError as e:
        print(f"  다운로드 실패: {e}")
        return None

def extract_frames(video_path: Path, output_prefix: str, fps: float = 2.0):
    """
    영상에서 프레임 추출

    Args:
        video_path: 영상 파일 경로
        output_prefix: 출력 파일 접두사
        fps: 초당 추출할 프레임 수 (기본 2fps = 0.5초마다 1프레임)
    """
    frames_dir = OUTPUT_DIR / "frames"
    frames_dir.mkdir(parents=True, exist_ok=True)

    output_pattern = str(frames_dir / f"{output_prefix}_%04d.jpg")

    print(f"  프레임 추출 중: {video_path.name} @ {fps}fps")
    cmd = [
        "ffmpeg",
        "-i", str(video_path),
        "-vf", f"fps={fps}",
        "-q:v", "2",  # 높은 품질
        output_pattern,
        "-y"  # 덮어쓰기
    ]

    try:
        subprocess.run(cmd, check=True, capture_output=True)
        # 추출된 프레임 수 확인
        frame_count = len(list(frames_dir.glob(f"{output_prefix}_*.jpg")))
        print(f"  완료: {frame_count} 프레임 추출됨")
        return frame_count
    except subprocess.CalledProcessError as e:
        print(f"  프레임 추출 실패: {e}")
        return 0

def process_local_video(video_path: str, output_prefix: str = None):
    """로컬 영상 파일에서 프레임 추출"""
    video_path = Path(video_path)
    if not video_path.exists():
        print(f"파일 없음: {video_path}")
        return

    if output_prefix is None:
        output_prefix = video_path.stem

    extract_frames(video_path, output_prefix)

def interactive_mode():
    """대화형 모드"""
    print("\n" + "=" * 60)
    print("바벨 운동 영상 프레임 추출기")
    print("=" * 60)
    print(SEARCH_KEYWORDS)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    while True:
        print("\n옵션:")
        print("  1. YouTube URL에서 프레임 추출")
        print("  2. 로컬 영상에서 프레임 추출")
        print("  3. 추출된 프레임 확인")
        print("  4. Roboflow로 업로드 가이드")
        print("  q. 종료")

        choice = input("\n선택: ").strip()

        if choice == "1":
            url = input("YouTube URL: ").strip()
            name = input("영상 이름 (예: squat_side_1): ").strip()
            if url and name:
                video = download_video(url, name)
                if video:
                    extract_frames(video, name)

        elif choice == "2":
            path = input("영상 파일 경로: ").strip()
            if path:
                process_local_video(path)

        elif choice == "3":
            frames_dir = OUTPUT_DIR / "frames"
            if frames_dir.exists():
                frames = list(frames_dir.glob("*.jpg"))
                print(f"\n추출된 프레임: {len(frames)}개")
                print(f"위치: {frames_dir}")
            else:
                print("아직 추출된 프레임이 없습니다.")

        elif choice == "4":
            print("""
=== Roboflow 업로드 가이드 ===

1. https://app.roboflow.com 접속
2. 새 프로젝트 생성: "barbell-plate-side"
3. Upload > "Select Files" 클릭
4. extracted_frames/frames 폴더의 이미지 선택
5. 업로드 후 라벨링 시작

라벨링 팁:
- 클래스: "barbell_plate_side"
- 바벨 플레이트의 원형 옆면만 bounding box로 표시
- 양쪽 끝단 모두 라벨링
- 바벨 없는 프레임은 라벨링하지 않음 (background)
""")

        elif choice.lower() == "q":
            break

def batch_process(urls_file: str):
    """
    URL 목록 파일에서 일괄 처리

    urls.txt 형식:
    https://youtube.com/watch?v=xxx|squat_side_1
    https://youtube.com/watch?v=yyy|bench_side_1
    """
    urls_path = Path(urls_file)
    if not urls_path.exists():
        print(f"파일 없음: {urls_path}")
        return

    for line in urls_path.read_text().strip().split("\n"):
        if "|" not in line:
            continue
        url, name = line.split("|", 1)
        video = download_video(url.strip(), name.strip())
        if video:
            extract_frames(video, name.strip())

if __name__ == "__main__":
    import sys

    if not check_dependencies():
        print("\n필요한 도구를 먼저 설치하세요.")
        sys.exit(1)

    if len(sys.argv) > 1:
        # 명령행 인자가 있으면 일괄 처리
        batch_process(sys.argv[1])
    else:
        # 대화형 모드
        interactive_mode()
