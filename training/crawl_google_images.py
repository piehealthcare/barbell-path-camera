#!/usr/bin/env python3
"""
Google Images 바벨 사진 크롤러
"""

import requests
import os
import time
import hashlib
from pathlib import Path
from urllib.parse import quote
import re

TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / 'labeling_images'

def get_image_urls(query, num_images=100):
    """Google Images에서 이미지 URL 추출"""
    urls = []

    # Google Images 검색 URL
    search_url = f"https://www.google.com/search?q={quote(query)}&tbm=isch&ijn=0"

    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }

    try:
        response = requests.get(search_url, headers=headers, timeout=10)

        # 이미지 URL 패턴 추출
        # Google Images는 데이터 속성에 이미지 URL을 포함
        patterns = [
            r'"(https?://[^"]+\.(?:jpg|jpeg|png|webp))"',
            r'\["(https?://[^"]+\.(?:jpg|jpeg|png|webp))"',
        ]

        for pattern in patterns:
            found = re.findall(pattern, response.text, re.IGNORECASE)
            for url in found:
                if 'gstatic' not in url and 'google' not in url:
                    urls.append(url)

        # 중복 제거
        urls = list(dict.fromkeys(urls))[:num_images]

    except Exception as e:
        print(f"검색 오류: {e}")

    return urls

def download_image(url, output_path):
    """이미지 다운로드"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=10, stream=True)

        if response.status_code == 200:
            content_type = response.headers.get('content-type', '')
            if 'image' in content_type:
                with open(output_path, 'wb') as f:
                    for chunk in response.iter_content(1024):
                        f.write(chunk)
                return True
    except Exception as e:
        pass
    return False

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # 검색 쿼리 목록
    queries = [
        # 바벨 운동 측면
        "barbell squat side view",
        "barbell deadlift side angle",
        "bench press side view",
        "barbell overhead press side",
        "barbell row side view",

        # 파워리프팅
        "powerlifting squat side",
        "powerlifting deadlift side",
        "powerlifting bench press side",

        # 바벨 끝단/플레이트
        "barbell plate closeup",
        "barbell end plate",
        "olympic barbell plate",
        "bumper plate barbell",

        # 한국어 검색
        "바벨 스쿼트 측면",
        "데드리프트 측면",
        "벤치프레스 측면",

        # 추가 검색어
        "squat form side view gym",
        "deadlift form check",
        "barbell exercise side angle",
        "weightlifting side view",
    ]

    total_downloaded = 0

    for query in queries:
        print(f"\n검색: {query}")
        urls = get_image_urls(query, num_images=50)
        print(f"  발견: {len(urls)}개 URL")

        downloaded = 0
        for url in urls:
            # 파일명 생성 (URL 해시)
            url_hash = hashlib.md5(url.encode()).hexdigest()[:12]
            query_prefix = query.replace(' ', '_')[:20]
            filename = f"google_{query_prefix}_{url_hash}.jpg"
            output_path = OUTPUT_DIR / filename

            if output_path.exists():
                continue

            if download_image(url, output_path):
                downloaded += 1
                total_downloaded += 1

                # 파일 크기 확인 (너무 작으면 삭제)
                if output_path.stat().st_size < 5000:  # 5KB 미만
                    output_path.unlink()
                    downloaded -= 1
                    total_downloaded -= 1

        print(f"  다운로드: {downloaded}개")
        time.sleep(1)  # Rate limiting

    print(f"\n=== 완료 ===")
    print(f"총 다운로드: {total_downloaded}개")
    print(f"저장 위치: {OUTPUT_DIR}")

if __name__ == '__main__':
    main()
