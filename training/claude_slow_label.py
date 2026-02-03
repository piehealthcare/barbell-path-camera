#!/usr/bin/env python3
"""Claude AI 느린 라벨링 (Rate limit 대응)"""
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

# 메타데이터 로드
if META_FILE.exists():
    with open(META_FILE) as f:
        metadata = json.load(f)
else:
    metadata = {}

# 미라벨링 이미지 중 바벨 포커스 영상만 선택
images = set(f.stem for f in IMAGES_DIR.glob("focused_*.jpg"))
labeled = set(f.stem for f in LABELS_DIR.glob("*.txt") if f.stem != "classes")
unlabeled = sorted(list(images - labeled))[:50]  # 50개만

print(f"바벨 포커스 이미지 라벨링", flush=True)
print(f"처리할 이미지: {len(unlabeled)}개", flush=True)

client = anthropic.Anthropic(api_key=API_KEY)
success = 0
no_barbell = 0

for i, img_stem in enumerate(unlabeled):
    img_path = IMAGES_DIR / f"{img_stem}.jpg"
    label_path = LABELS_DIR / f"{img_stem}.txt"
    
    print(f"[{i+1}/{len(unlabeled)}] {img_stem[-30:]}...", end=" ", flush=True)
    
    try:
        with open(img_path, 'rb') as f:
            image_data = base64.standard_b64encode(f.read()).decode('utf-8')
        
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=256,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image", "source": {"type": "base64", "media_type": "image/jpeg", "data": image_data}},
                    {"type": "text", "text": "바벨 원판 끝단 위치를 JSON으로. 박스크기 w,h는 0.01~0.1 정도. {\"found\":bool,\"boxes\":[{\"cx\":float,\"cy\":float,\"w\":float,\"h\":float}]}"}
                ]
            }]
        )
        
        response = message.content[0].text
        match = re.search(r'\{.*\}', response, re.DOTALL)
        
        if match:
            data = json.loads(match.group())
            if data.get("found") and data.get("boxes"):
                lines = [f"0 {b['cx']:.4f} {b['cy']:.4f} {b['w']:.4f} {b['h']:.4f}" for b in data["boxes"]]
                with open(label_path, 'w') as f:
                    f.write('\n'.join(lines))
                metadata[img_stem] = "claude"
                success += 1
                print(f"O ({len(lines)})", flush=True)
            else:
                with open(label_path, 'w') as f:
                    f.write('')
                metadata[img_stem] = "claude"
                no_barbell += 1
                print("X", flush=True)
                
    except Exception as e:
        if "rate" in str(e).lower():
            print("대기(2분)...", flush=True)
            time.sleep(120)
        else:
            print(f"err", flush=True)
    
    time.sleep(5)  # 5초 간격

with open(META_FILE, 'w') as f:
    json.dump(metadata, f, indent=2)

print(f"\n완료: 바벨발견 {success}개, 없음 {no_barbell}개", flush=True)
