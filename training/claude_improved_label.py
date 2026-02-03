#!/usr/bin/env python3
"""Claude AI 개선된 라벨링 - 수동 라벨 예시 참조"""
import anthropic
import base64
import json
import time
from pathlib import Path
import re

import os
API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
IMAGES_DIR = Path("labeling_images")
LABELS_DIR = Path("labeling_labels")
META_FILE = LABELS_DIR / "_metadata.json"

LABELS_DIR.mkdir(exist_ok=True)

# 메타데이터 로드
if META_FILE.exists():
    with open(META_FILE) as f:
        metadata = json.load(f)
else:
    metadata = {}

# 수동 라벨 예시 준비
def get_example_context():
    return """## 참고: 바벨 플레이트 끝단 라벨링 예시

기존 수동 라벨링된 데이터 예시:
- 박스 크기: 보통 w=0.01~0.05, h=0.02~0.10 (정규화)
- 바벨 플레이트의 가장 바깥쪽 가장자리(끝)만 표시
- 원판이 보이면 양쪽 끝 2개 표시
- 프레임에 일부만 보이면 보이는 끝만 표시

라벨 예시:
1. 양쪽 끝: [{"cx":0.06,"cy":0.66,"w":0.015,"h":0.023}, {"cx":0.93,"cy":0.56,"w":0.024,"h":0.029}]
2. 한쪽만: [{"cx":0.87,"cy":0.36,"w":0.015,"h":0.056}]
3. 큰 원판: [{"cx":0.24,"cy":0.42,"w":0.051,"h":0.105}]

박스는 원판 끝단의 작은 영역만 감싸야 합니다 (전체 원판 아님)."""

# 미라벨링 이미지 찾기
images = set(f.stem for f in IMAGES_DIR.glob("*.jpg"))
labeled = set(f.stem for f in LABELS_DIR.glob("*.txt") if f.stem != "classes")
unlabeled = sorted(list(images - labeled))

print(f"Claude AI 개선된 라벨링 시작", flush=True)
print(f"처리할 이미지: {len(unlabeled)}개", flush=True)
print("=" * 50, flush=True)

client = anthropic.Anthropic(api_key=API_KEY)

success = 0
failed = 0
no_barbell = 0

# 200개 처리
batch_size = 200
unlabeled = unlabeled[:batch_size]

example_context = get_example_context()

for i, img_stem in enumerate(unlabeled):
    img_path = IMAGES_DIR / f"{img_stem}.jpg"
    label_path = LABELS_DIR / f"{img_stem}.txt"
    
    if not img_path.exists():
        continue
    
    print(f"[{i+1}/{len(unlabeled)}] {img_stem[:40]}...", end=" ", flush=True)
    
    try:
        with open(img_path, 'rb') as f:
            image_data = base64.standard_b64encode(f.read()).decode('utf-8')
        
        prompt = f"""{example_context}

이 이미지에서 바벨 플레이트(원판)의 끝단(가장자리)을 찾아 바운딩 박스로 표시해주세요.

규칙:
1. 바벨이 보이면 원판의 양쪽 끝 위치를 표시 (보통 2개)
2. 일부만 보이면 보이는 끝만 표시
3. 바벨/원판이 안 보이면 found: false
4. 박스는 끝단의 작은 영역만 (w,h가 너무 크면 안됨)

JSON만 응답: {{"found":bool,"boxes":[{{"cx":float,"cy":float,"w":float,"h":float}}]}}"""

        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=512,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image", "source": {"type": "base64", "media_type": "image/jpeg", "data": image_data}},
                    {"type": "text", "text": prompt}
                ]
            }]
        )
        
        response_text = message.content[0].text
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        
        if json_match:
            data = json.loads(json_match.group())
            
            if data.get("found") and data.get("boxes"):
                lines = []
                for box in data["boxes"]:
                    cx = max(0, min(1, float(box['cx'])))
                    cy = max(0, min(1, float(box['cy'])))
                    w = max(0.005, min(0.2, float(box['w'])))
                    h = max(0.01, min(0.3, float(box['h'])))
                    lines.append(f"0 {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}")
                
                with open(label_path, 'w') as f:
                    f.write('\n'.join(lines))
                
                metadata[img_stem] = "claude"
                success += 1
                print(f"바벨 {len(lines)}개", flush=True)
            else:
                with open(label_path, 'w') as f:
                    f.write('')
                metadata[img_stem] = "claude"
                no_barbell += 1
                print("없음", flush=True)
        else:
            failed += 1
            print("파싱실패", flush=True)
            
    except Exception as e:
        failed += 1
        err_msg = str(e)
        if "rate" in err_msg.lower() or "429" in err_msg:
            print(f"Rate limit! 60초 대기...", flush=True)
            time.sleep(60)
        else:
            print(f"에러", flush=True)
    
    # 메타데이터 저장 (10개마다)
    if (i + 1) % 10 == 0:
        with open(META_FILE, 'w') as f:
            json.dump(metadata, f, indent=2)
    
    # 1.5초 간격
    time.sleep(1.5)

# 최종 저장
with open(META_FILE, 'w') as f:
    json.dump(metadata, f, indent=2)

print("=" * 50, flush=True)
print(f"완료! 성공:{success} 바벨없음:{no_barbell} 실패:{failed}", flush=True)
