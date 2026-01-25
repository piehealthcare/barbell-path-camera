#!/usr/bin/env python3
"""
Bing Images 바벨 사진 크롤러
"""

from bing_image_downloader import downloader
from pathlib import Path
import shutil
import os

TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / 'labeling_images'
TEMP_DIR = TRAINING_DIR / 'bing_temp'

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    TEMP_DIR.mkdir(parents=True, exist_ok=True)

    # 검색 쿼리 목록
    queries = [
        # 바벨 운동 측면
        "barbell squat side view",
        "barbell deadlift side angle",
        "bench press side view form",
        "barbell overhead press side",

        # 파워리프팅
        "powerlifting squat competition",
        "powerlifting deadlift side",
        "powerlifting bench press",

        # 바벨 끝단/플레이트
        "barbell plate gym",
        "olympic barbell bumper plate",

        # 운동 자세
        "squat form check side",
        "deadlift form side view",
        "weightlifting barbell side",

        # 추가
        "gym barbell exercise",
        "barbell workout side angle",
    ]

    total_copied = 0

    for query in queries:
        print(f"\n검색: {query}")

        try:
            # Bing에서 이미지 다운로드
            downloader.download(
                query,
                limit=30,
                output_dir=str(TEMP_DIR),
                adult_filter_off=True,
                force_replace=False,
                timeout=30
            )

            # 다운로드된 이미지를 labeling_images로 복사
            query_dir = TEMP_DIR / query
            if query_dir.exists():
                copied = 0
                for img_file in query_dir.glob('*'):
                    if img_file.suffix.lower() in ['.jpg', '.jpeg', '.png', '.webp', '.gif']:
                        # 새 파일명
                        new_name = f"bing_{query.replace(' ', '_')[:15]}_{img_file.name}"
                        dest = OUTPUT_DIR / new_name

                        if not dest.exists():
                            shutil.copy(img_file, dest)
                            copied += 1
                            total_copied += 1

                print(f"  복사: {copied}개")

        except Exception as e:
            print(f"  오류: {e}")

    # 임시 디렉토리 삭제
    if TEMP_DIR.exists():
        shutil.rmtree(TEMP_DIR)

    print(f"\n=== 완료 ===")
    print(f"총 추가된 이미지: {total_copied}개")
    print(f"전체 이미지 수: {len(list(OUTPUT_DIR.glob('*')))}개")

if __name__ == '__main__':
    main()
