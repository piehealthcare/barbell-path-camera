# 바벨 플레이트 끝단 감지 모델 학습 가이드

## 목차
1. [개요](#개요)
2. [환경 설정](#환경-설정)
3. [데이터셋 준비](#데이터셋-준비)
4. [Roboflow 사용법](#roboflow-사용법)
5. [모델 학습](#모델-학습)
6. [모델 Export](#모델-export)
7. [앱에 적용](#앱에-적용)
8. [문제 해결](#문제-해결)

---

## 개요

### 목표
바벨 패스(Bar Path) 트래킹을 위해 **바벨 플레이트의 옆면(끝단)**을 정확히 감지하는 YOLOv8 모델 학습

### 왜 바벨 끝단인가?
- 바벨 전체를 감지하면 bounding box가 너무 커서 정확한 궤적을 그릴 수 없음
- **플레이트 옆면의 중심점**이 바패스의 기준점
- 양쪽 끝단을 트래킹하면 바벨의 기울기도 분석 가능

### 현재 상태
- 클래스: `barbell_plate_side` (1개)
- 학습 데이터: 261개 이미지 (더 많은 데이터 필요)
- mAP50: 0.818

---

## 환경 설정

### 필수 도구 설치

```bash
# Python 3.9+ 필요
python3 --version

# 필수 패키지 설치
pip3 install ultralytics torch torchvision

# 영상 다운로드 도구 (선택)
brew install yt-dlp ffmpeg
```

### 디렉토리 구조

```
barbell_path_camera/
├── training/
│   ├── barbell_plate_dataset/     # 학습 데이터셋
│   │   ├── data.yaml
│   │   ├── train/images/
│   │   ├── train/labels/
│   │   ├── valid/images/
│   │   └── valid/labels/
│   ├── runs/detect/               # 학습 결과
│   ├── train_plate_detector.py    # 학습 스크립트
│   └── TRAINING_GUIDE.md          # 이 문서
└── example/ios/Runner/
    └── barbell_detector.mlpackage # iOS 모델
```

---

## 데이터셋 준비

### 방법 1: Roboflow 사용 (권장)

1. https://app.roboflow.com 접속
2. 새 프로젝트 생성: `barbell-plate-side`
3. Annotation Type: **Object Detection**
4. 이미지 업로드 및 라벨링
5. Export → YOLOv8 포맷

### 방법 2: YouTube 영상에서 프레임 추출

```bash
cd training

# 대화형 모드로 프레임 추출
python3 extract_frames_from_videos.py

# 또는 URL 목록 파일로 일괄 처리
# urls.txt 형식: URL|이름
python3 extract_frames_from_videos.py urls.txt
```

### 방법 3: 기존 바벨 데이터에서 플레이트 영역 추출

```bash
cd training
python3 crop_plate_regions.py
```

### 권장 데이터 수량

| 카테고리 | 최소 | 권장 |
|---------|------|------|
| 스쿼트 | 100장 | 200장 |
| 벤치 프레스 | 100장 | 200장 |
| 데드리프트 | 100장 | 200장 |
| 오버헤드 프레스 | 50장 | 100장 |
| **Background (바벨 없음)** | **100장** | **200장** |
| **총합** | **450장** | **900장+** |

⚠️ **Background 이미지 필수**: 체육관 배경, 다른 장비 등 바벨이 없는 이미지를 반드시 포함!

---

## Roboflow 사용법

### 1. 프로젝트 생성

```
Roboflow.com → Create New Project
- Project Name: barbell-plate-side
- Project Type: Object Detection
- Annotation Group: (원하는 이름)
```

### 2. 이미지 업로드

```
Upload → Select Files → training/extracted_frames/*.jpg
```

### 3. 라벨링

클래스 이름: `barbell_plate_side`

```
[올바른 라벨링 예시]

           바벨
    ┌──────┬──────┐
────●──────┴──────●────
    └──┐          ┌──┘
       │          │
    이 영역만    이 영역만
    라벨링      라벨링
```

**라벨링 팁:**
- 플레이트 옆면의 **원형 부분만** bounding box로 표시
- 바벨 샤프트(막대)는 포함하지 않음
- 여러 플레이트가 겹쳐있으면 **가장 바깥쪽**만 라벨링
- 부분적으로 가려진 경우 **보이는 부분만** 라벨링
- Background 이미지는 라벨링하지 않음 (빈 annotation)

### 4. Generate & Export

```
Generate →
  - Train/Valid/Test Split: 70/20/10
  - Preprocessing:
    - Auto-Orient: ✅
    - Resize: 640x640 (Stretch)
  - Augmentation (선택):
    - Flip: Horizontal
    - Rotation: ±15°
    - Brightness: ±15%
    - Blur: up to 1px

Export → Format: YOLOv8 → Download zip
```

### 5. 데이터셋 적용

```bash
cd training
unzip ~/Downloads/barbell-plate-side.v1-*.zip -d barbell_plate_dataset/
```

---

## 모델 학습

### 기본 학습

```bash
cd training
python3 train_plate_detector.py
```

### 커스텀 학습 (Python)

```python
from ultralytics import YOLO

# 베이스 모델 로드
model = YOLO("yolov8n.pt")  # nano 모델 (빠름)
# model = YOLO("yolov8s.pt")  # small 모델 (더 정확)

# 학습 시작
results = model.train(
    data="barbell_plate_dataset/data.yaml",
    epochs=100,           # 에포크 수
    imgsz=320,            # 이미지 크기 (모바일용 작게)
    batch=16,             # 배치 크기
    name="barbell_plate_detector",
    patience=20,          # 조기 종료 patience
    device="mps",         # Apple Silicon: "mps", NVIDIA: "cuda", CPU: "cpu"
    workers=4,

    # Augmentation
    hsv_h=0.015,          # 색조 변화
    hsv_s=0.7,            # 채도 변화
    hsv_v=0.4,            # 명도 변화
    degrees=10,           # 회전
    translate=0.1,        # 이동
    scale=0.5,            # 스케일
    flipud=0.5,           # 상하 반전
    fliplr=0.5,           # 좌우 반전
    mosaic=1.0,           # 모자이크
)
```

### 학습 진행 모니터링

```bash
# TensorBoard로 모니터링
tensorboard --logdir runs/detect/barbell_plate_detector

# 또는 브라우저에서 확인
open runs/detect/barbell_plate_detector/results.png
```

### 학습 결과 지표

- **mAP50**: 0.8 이상 권장
- **mAP50-95**: 0.4 이상 권장
- **Precision**: False Positive가 적을수록 좋음
- **Recall**: False Negative가 적을수록 좋음

---

## 모델 Export

### CoreML (iOS)

```python
from ultralytics import YOLO

model = YOLO("runs/detect/barbell_plate_detector/weights/best.pt")
model.export(
    format="coreml",
    imgsz=320,
    half=True,    # FP16으로 용량 감소
    nms=True,     # NMS 포함
)
```

### TFLite (Android)

```python
model.export(
    format="tflite",
    imgsz=320,
    half=True,
)
```

---

## 앱에 적용

### iOS (CoreML)

```bash
# 모델 복사
cp -r runs/detect/barbell_plate_detector/weights/best.mlpackage \
      ../example/ios/Runner/barbell_detector.mlpackage

# Xcode에서 빌드
cd ../example
flutter run -d <device_id> --release
```

### Android (TFLite)

```bash
# 모델 복사
cp runs/detect/barbell_plate_detector/weights/best_float16.tflite \
   ../barbell_tracking/assets/ml/barbell_detector.tflite
```

---

## 문제 해결

### 문제 1: 모든 것을 바벨로 인식 (100% 신뢰도)

**원인**: 오버피팅 - 데이터셋이 작거나 negative sample 부족

**해결책**:
1. Background 이미지 추가 (체육관 배경, 사람만 있는 이미지 등)
2. 데이터 augmentation 강화
3. 다양한 환경의 이미지 추가

### 문제 2: 바벨을 감지하지 못함

**원인**: 학습 데이터가 실제 환경과 다름

**해결책**:
1. 실제 사용 환경과 유사한 이미지로 학습
2. 다양한 조명, 각도의 이미지 추가
3. 데이터 augmentation 사용

### 문제 3: TFLite Export 실패

**원인**: TensorFlow/Keras 버전 호환성 문제

**해결책**:
```bash
# 호환되는 버전 설치
pip install tensorflow==2.12.0 tf-keras==2.12.0
pip install onnx2tf>=1.26.3
```

### 문제 4: mAP가 낮음

**원인**: 데이터 품질 또는 양 부족

**해결책**:
1. 라벨링 품질 확인 (bounding box가 정확한지)
2. 데이터 양 증가
3. 에포크 수 증가
4. 더 큰 모델 사용 (yolov8s, yolov8m)

---

## 자동화 스크립트

### 크롤링 + 학습 자동화

```bash
cd training
python3 auto_crawl_and_train.py
```

이 스크립트는:
1. YouTube에서 바벨 운동 영상 다운로드
2. 프레임 추출
3. 기존 모델로 pseudo-labeling
4. 데이터셋 병합
5. 모델 재학습

⚠️ pseudo-labeling은 노이즈가 있을 수 있으므로, 수동 라벨링이 더 정확함

---

## 참고 자료

- [Ultralytics YOLOv8 문서](https://docs.ultralytics.com/)
- [Roboflow 문서](https://docs.roboflow.com/)
- [CoreML 문서](https://developer.apple.com/documentation/coreml)

---

## 현재 Roboflow 데이터셋

현재 Roboflow에 업로드된 공식 데이터셋은 없습니다.

직접 데이터셋을 만들어 Roboflow에 업로드하거나, 제공된 스크립트로 데이터를 수집해야 합니다.
