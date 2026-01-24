# 바벨 플레이트 옆면(끝단) 데이터셋 수집 가이드

## 목표
바벨 패스 트래킹을 위해 **바벨 플레이트의 옆면(끝단)**만 정확히 감지하는 모델 학습

## 왜 바벨 끝단인가?
- 바패스 트래킹은 바벨의 한 지점을 추적해야 함
- 바벨 전체를 감지하면 bounding box가 너무 커서 정확한 궤적을 그릴 수 없음
- **플레이트 옆면의 중심점**이 바패스의 기준점

## 촬영 가이드

### 1. 촬영 환경
- 실제 체육관 환경
- 다양한 조명 조건 (자연광, 형광등, LED)
- 다양한 배경 (벽, 거울, 다른 장비)

### 2. 촬영 각도
```
[측면 촬영 - 필수]

      사용자
        │
    ┌───┼───┐
    │   │   │  ← 바벨
────●───┴───●────
    ↑           ↑
  카메라      카메라
 (측면1)    (측면2)
```

**측면에서 촬영** (바벨과 수직)
- 바벨 플레이트가 원형으로 보이는 각도
- 양쪽 끝단이 모두 보이도록

### 3. 운동 동작
- **스쿼트**: 하강/상승 전 과정
- **벤치 프레스**: 시작 위치부터 끝까지
- **데드리프트**: 바닥에서 들어올릴 때
- **오버헤드 프레스**: 어깨 높이에서 머리 위까지

### 4. 다양한 상황
- [ ] 정지 상태 (각 위치에서)
- [ ] 움직이는 상태 (모션 블러 포함)
- [ ] 다양한 플레이트 크기 (5kg, 10kg, 15kg, 20kg, 25kg)
- [ ] 다양한 플레이트 색상 (검정, 빨강, 파랑, 노랑, 초록)
- [ ] 다양한 거리 (1m, 2m, 3m)

### 5. 권장 이미지 수
| 카테고리 | 최소 | 권장 |
|---------|------|------|
| 스쿼트 | 50장 | 100장 |
| 벤치 프레스 | 50장 | 100장 |
| 데드리프트 | 50장 | 100장 |
| 기타 운동 | 30장 | 50장 |
| **Background (바벨 없음)** | **50장** | **100장** |
| **총합** | **230장** | **450장** |

⚠️ **Background 이미지 중요**: 바벨이 없는 체육관 배경 이미지를 반드시 포함!

## 라벨링 가이드

### 1. Roboflow 설정
1. https://app.roboflow.com 접속
2. 새 프로젝트 생성: `barbell-plate-side`
3. Annotation Type: **Object Detection**

### 2. 클래스 정의
```
barbell_plate_side (바벨 플레이트 옆면)
```

**하나의 클래스만 사용!**

### 3. 라벨링 방법

```
[올바른 라벨링]

           바벨
    ┌──────┬──────┐
────●──────┴──────●────
    └──┐          ┌──┘
       │          │
    이 영역만    이 영역만
    라벨링      라벨링
```

**플레이트 옆면(원형 부분)만 bounding box로 표시**

### 4. 라벨링 팁
- 플레이트 옆면의 **원형 부분만** 선택
- 바벨 샤프트(막대)는 포함하지 않음
- 여러 플레이트가 겹쳐있으면 **가장 바깥쪽 플레이트**만 라벨링
- 부분적으로 가려진 플레이트는 **보이는 부분만** 라벨링

### 5. Background 이미지
- 바벨이 없는 이미지는 라벨링하지 않음 (빈 annotation)
- 체육관 배경, 다른 장비, 사람만 있는 이미지

## 데이터셋 Export

### Roboflow에서 Export
1. Generate 버튼 클릭
2. Preprocessing:
   - Auto-Orient: ✅
   - Resize: 640x640 (Stretch)
3. Augmentation (선택):
   - Flip: Horizontal, Vertical
   - Rotation: ±15°
   - Brightness: ±20%
4. Format: **YOLOv8**
5. Download

### 폴더 구조
```
barbell_plate_side/
├── data.yaml
├── train/
│   ├── images/
│   └── labels/
├── valid/
│   ├── images/
│   └── labels/
└── test/
    ├── images/
    └── labels/
```

## 학습 명령어

```bash
cd training

# 데이터셋 다운로드 후
python3 -c "
from ultralytics import YOLO

model = YOLO('yolov8n.pt')
results = model.train(
    data='barbell_plate_side/data.yaml',
    epochs=100,
    imgsz=320,
    batch=16,
    name='barbell_plate_detector',
    patience=20,
    device='mps',  # Mac
)
"
```

## 기대 결과
- 바벨 플레이트 옆면만 정확히 감지
- False Positive 감소 (배경을 바벨로 인식하지 않음)
- 정확한 바패스 트래킹 가능

## 체크리스트
- [ ] 200+ 이미지 촬영
- [ ] 50+ Background 이미지 포함
- [ ] Roboflow에서 라벨링 완료
- [ ] YOLOv8 포맷으로 Export
- [ ] 모델 학습
- [ ] CoreML/TFLite Export
- [ ] 앱에 적용 및 테스트
