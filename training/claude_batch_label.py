#!/usr/bin/env python3
"""Claude AI 일괄 라벨링 스크립트 (Rate limit 대응)"""
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

# 미라벨링 이미지 찾기
images = set(f.stem for f in IMAGES_DIR.glob("*.jpg"))
labeled = set(f.stem for f in LABELS_DIR.glob("*.txt") if f.stem != "classes")
unlabeled = sorted(list(images - labeled))

print(f"Claude AI 일괄 라벨링 시작", flush=True)
print(f"처리할 이미지: {len(unlabeled)}개", flush=True)
print("=" * 50, flush=True)

client = anthropic.Anthropic(api_key=API_KEY)

success = 0
failed = 0
no_barbell = 0

# 100개만 처리 (테스트)
batch_size = 100
unlabeled = unlabeled[:batch_size]

for i, img_stem in enumerate(unlabeled):
    img_path = IMAGES_DIR / f"{img_stem}.jpg"
    label_path = LABELS_DIR / f"{img_stem}.txt"
    
    if not img_path.exists():
        continue
    
    print(f"[{i+1}/{len(unlabeled)}] {img_stem}...", end=" ", flush=True)
    
    try:
        with open(img_path, 'rb') as f:
            image_data = base64.standard_b64encode(f.read()).decode('utf-8')
        
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=512,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image", "source": {"type": "base64", "media_type": "image/jpeg", "data": image_data}},
                    {"type": "text", "text": "바벨 플레이트 끝단 바운딩박스. 정규화좌표(0~1). JSON만: {\"found\":bool,\"boxes\":[{\"cx\":float,\"cy\":float,\"w\":float,\"h\":float}]}"}
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
                    lines.append(f"0 {float(box['cx']):.6f} {float(box['cy']):.6f} {float(box['w']):.6f} {float(box['h']):.6f}")
                
                with open(label_path, 'w') as f:
                    f.write('\n'.join(lines))
                
                metadata[img_stem] = "claude"
                success += 1
                print(f"바벨발견 ({len(lines)}개)", flush=True)
            else:
                with open(label_path, 'w') as f:
                    f.write('')
                metadata[img_stem] = "claude"
                no_barbell += 1
                print("바벨없음", flush=True)
        else:
            failed += 1
            print("파싱실패", flush=True)
            
    except Exception as e:
        failed += 1
        err_msg = str(e)
        if "rate" in err_msg.lower() or "429" in err_msg:
            print(f"Rate limit! 120초 대기...", flush=True)
            time.sleep(120)
        else:
            print(f"에러: {err_msg[:50]}", flush=True)
    
    # 메타데이터 저장
    with open(META_FILE, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    # 2초 간격 (Rate limit 방지)
    time.sleep(2)

print("=" * 50, flush=True)
print(f"완료! 성공:{success} 바벨없음:{no_barbell} 실패:{failed}", flush=True)
