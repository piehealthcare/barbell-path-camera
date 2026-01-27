#!/usr/bin/env python3
"""
영상에서 프레임 추출 스크립트
- raw_videos 폴더의 모든 영상에서 프레임 추출
- labeling_images 폴더에 저장
"""

import cv2
from pathlib import Path
import sys

TRAINING_DIR = Path(__file__).parent
VIDEOS_DIR = TRAINING_DIR / 'raw_videos'
OUTPUT_DIR = TRAINING_DIR / 'labeling_images'

def extract_frames(video_path: Path, fps_sample: int = 5):
    """
    영상에서 프레임 추출

    Args:
        video_path: 영상 파일 경로
        fps_sample: 초당 추출할 프레임 수 (기본 5fps)
    """
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        print(f"  [오류] 영상을 열 수 없음: {video_path.name}")
        return 0

    video_fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = total_frames / video_fps if video_fps > 0 else 0

    print(f"  영상 정보: {video_fps:.1f}fps, {total_frames}프레임, {duration:.1f}초")

    # 샘플링 간격 계산
    frame_interval = max(1, int(video_fps / fps_sample))

    frame_count = 0
    saved_count = 0
    video_name = video_path.stem

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        if frame_count % frame_interval == 0:
            # 파일명: 영상이름_프레임번호.jpg
            output_path = OUTPUT_DIR / f"{video_name}_{frame_count:06d}.jpg"
            cv2.imwrite(str(output_path), frame)
            saved_count += 1

        frame_count += 1

    cap.release()
    return saved_count

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # 지원 포맷
    video_extensions = ['.mp4', '.mov', '.avi', '.mkv', '.m4v', '.MP4', '.MOV']

    videos = [f for f in VIDEOS_DIR.glob('*') if f.suffix in video_extensions]

    if not videos:
        print(f"영상이 없습니다.")
        print(f"영상 폴더: {VIDEOS_DIR}")
        print(f"\n이 폴더에 영상 파일을 넣어주세요.")
        return

    print(f"=== 프레임 추출 시작 ===")
    print(f"영상 폴더: {VIDEOS_DIR}")
    print(f"출력 폴더: {OUTPUT_DIR}")
    print(f"발견된 영상: {len(videos)}개\n")

    # FPS 설정 (커맨드 라인 인자로 받기)
    fps_sample = 5  # 기본값: 초당 5프레임
    if len(sys.argv) > 1:
        try:
            fps_sample = int(sys.argv[1])
        except ValueError:
            pass

    print(f"샘플링: 초당 {fps_sample}프레임\n")

    total_saved = 0
    for i, video_path in enumerate(videos, 1):
        print(f"[{i}/{len(videos)}] {video_path.name}")
        saved = extract_frames(video_path, fps_sample)
        total_saved += saved
        print(f"  -> {saved}개 프레임 저장\n")

    print(f"=== 완료 ===")
    print(f"총 {total_saved}개 프레임 추출")
    print(f"저장 위치: {OUTPUT_DIR}")
    print(f"\n다음 단계: http://localhost:8085 에서 라벨링")

if __name__ == '__main__':
    main()
