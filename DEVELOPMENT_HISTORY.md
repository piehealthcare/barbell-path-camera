# Barbell Path Camera 개발 히스토리

## 프로젝트 개요

실시간 바벨 경로 추적 Flutter 앱. 마커 없이 순수 컴퓨터 비전으로 바벨 끝단(플레이트)을 감지하고 경로를 추적함.

## 개발 일자
- 시작일: 2026-01-24
- 최종 업데이트: 2026-01-25

---

## 1. 완료된 작업

### 1.1 카메라 기능 구현
- Flutter `camera` 패키지 기반 실시간 카메라 프리뷰
- 카메라 방향/비율 문제 수정 완료
- 후면 카메라 자동 선택

### 1.2 Web Labeling Tool (localhost:8085)
- **Features**:
  - 이미지 리스트 표시 (라벨 상태: 수동/YOLO자동/Claude)
  - 클릭으로 바운딩 박스 생성
  - 저장 버튼으로 수동 라벨 확정 + 다음 이미지 자동 이동
  - YOLO 자동 라벨링 기능
  - 데이터셋 Export (80/20 train/valid 분할)
  - 모델 학습 UI (이어서 학습 / 새로 학습)
  - 학습 완료 시 자동 CoreML 변환 및 iOS 앱에 복사

- **Important UX Decision**:
  - 이미지 전환 시 자동 저장 안함 (사용자 요청)
  - 저장 버튼을 눌러야만 "수동" 라벨로 확정

### 1.3 YOLOv8 바벨 감지 모델 학습
- **최종 데이터셋**: 664개 수동 라벨링 이미지
- **분할**: 485 train / 122 valid (80/20)
- **모델**: YOLOv8 nano (3M parameters)
- **학습 설정**:
  ```python
  model = YOLO('yolov8n.pt')
  results = model.train(
      data='./barbell_plate_dataset_new/data.yaml',
      epochs=30,
      imgsz=320,
      batch=8,
      patience=10,
      device='mps',  # Apple M3 Pro GPU
  )
  ```
- **최종 모델**: barbell_endpoint13
- **결과**: mAP50 = ~0.90

### 1.4 모델 Export
- **CoreML**: `barbell_detector.mlpackage` (6MB) - iOS용
- **위치**: `example/ios/Runner/barbell_detector.mlpackage`

### 1.5 Flutter 앱 구현
- ultralytics_yolo 패키지 통합
- YOLOView 위젯 기반 실시간 감지
- 패스 궤적 시각화 (CustomPainter)
- 트래킹 시작/정지 버튼
- 패스 초기화 기능

### 1.6 데이터 수집 도구
- YouTube 영상 크롤링 스크립트 개발
  - `crawl_side_view.py` - 측면 촬영 바벨 운동 영상
  - `crawl_hq_barbell.py` - 720p+ 고화질 영상
  - `crawl_shorts.py` - YouTube Shorts
  - `crawl_new_barbell.py` - 중복 방지 크롤링 (최종 버전)
- 프레임 추출: 2-3fps, 1280px 리사이즈

---

## 2. 프로젝트 구조

```
barbell_path_camera/
├── barbell_tracking/           # Flutter 패키지
│   ├── lib/
│   │   └── src/
│   │       ├── domain/model/
│   │       │   └── barbell_detection.dart
│   │       └── service/
│   │           ├── ml_inference_service.dart
│   │           └── mock_ml_inference_service.dart
│   ├── assets/ml/
│   │   ├── barbell_detector.tflite
│   │   └── labels.txt
│   └── pubspec.yaml
├── example/                    # 예제 앱
│   ├── lib/main.dart
│   └── ios/Runner/
│       └── barbell_detector.mlpackage  # CoreML 모델
└── training/                   # 모델 학습
    ├── labeling_server.py      # Web labeling tool
    ├── labeling_images/        # Training images (664)
    ├── labeling_labels/        # YOLO format labels
    │   └── _metadata.json      # Label type metadata
    ├── barbell_plate_dataset_new/  # Exported dataset
    │   ├── train/
    │   └── valid/
    ├── runs/detect/            # Training results
    │   └── barbell_endpoint13/ # Latest model
    ├── crawl_new_barbell.py    # Video crawler
    └── downloaded_video_ids.txt # Downloaded video tracking
```

---

## 3. 핵심 의존성

### barbell_tracking/pubspec.yaml
```yaml
dependencies:
  camera: ^0.11.0
  flutter_riverpod: ^2.6.1
  ultralytics_yolo: ^0.1.34  # 0.2.0은 Swift 컴파일 에러 있음
  hive: ^2.2.3
  freezed_annotation: ^2.4.1
```

---

## 4. 현재 상태 및 문제점

### 4.1 해결된 문제
- [x] 카메라 방향/비율 문제
- [x] 모델 학습 및 export
- [x] Flutter 패키지 구조
- [x] Web labeling tool 구현
- [x] YOLO 자동라벨 → 수동 저장 분리 (UX 개선)
- [x] CoreML 모델을 iOS 프로젝트에 추가 완료
- [x] Xcode 프로젝트 모델 참조 수정 (barbell_detector.mlpackage)

### 4.2 알려진 문제
- [ ] 무선 iPhone 실행 시 에러 발생 (Xcode에서 직접 실행 필요)
- [ ] 모델 정확도 개선 필요 (더 많은 라벨링 데이터 필요)
- [ ] 실제 바벨 인식 테스트 필요

### 4.3 데이터셋 현황
- 현재 데이터셋: 664장 (수동 라벨링)
- 권장: 1000+ 이미지로 추가 학습

---

## 5. iOS 모델 배포 방법

### CoreML 모델 추가
1. Xcode에서 `example/ios/Runner.xcodeproj` 열기
2. `barbell_detector.mlpackage`를 Runner 타겟으로 드래그
3. "Copy items if needed" 체크
4. Target Membership에서 Runner 체크

### 모델 경로
- iOS: `barbell_detector.mlpackage` (CoreML)
- Flutter에서 참조: `modelPath: 'barbell_detector.mlpackage'`

---

## 6. Label Types

| Type | Description |
|------|-------------|
| `manual` | 사용자가 저장 버튼으로 확정한 라벨 |
| `auto` | YOLO 모델 자동 라벨링 (검증 필요) |
| `claude` | Claude API를 통한 자동 라벨링 (미사용) |

**주의**: 모델 학습 시 `manual` 라벨만 사용해야 함

---

## 7. 주요 코드 참조

### BarbellDetection 모델
```dart
@freezed
class BarbellDetection with _$BarbellDetection {
  const factory BarbellDetection({
    required int frameIndex,
    required double timestamp,
    required double centerX,      // 0-1 정규화
    required double centerY,      // 0-1 정규화
    required double boxLeft,
    required double boxTop,
    required double boxWidth,
    required double boxHeight,
    required double confidence,
  }) = _BarbellDetection;
}
```

### YOLOView 사용
```dart
YOLOView(
  modelPath: 'barbell_detector.mlpackage',
  task: YOLOTask.detect,
  showNativeUI: true,
  showOverlays: true,
  confidenceThreshold: 0.25,
  onResult: (results) {
    // 감지 결과 처리
  },
)
```

---

## 8. 명령어 모음

### Labeling Server 실행
```bash
cd training
python3 labeling_server.py
# http://localhost:8085
```

### 새로운 영상 크롤링
```bash
cd training
python3 crawl_new_barbell.py
```

### 모델 학습 (CLI)
```bash
cd training
python3 -c "
from ultralytics import YOLO
model = YOLO('yolov8n.pt')
model.train(data='./barbell_plate_dataset_new/data.yaml', epochs=30, imgsz=320)
model.export(format='coreml')
"
```

### Flutter 빌드
```bash
cd example
flutter pub get
flutter build ios --release
flutter run -d <device_id> --release
```

### Xcode에서 직접 실행
```bash
cd example/ios
open Runner.xcworkspace
# Product > Run
```

---

## 9. Training History

| Model | Date | Images | mAP50 | Notes |
|-------|------|--------|-------|-------|
| barbell_endpoint1-12 | 01-25 | Mixed | ~0.90 | YOLO 자동라벨 포함 |
| barbell_endpoint13 | 01-25 | 664 | ~0.90 | 수동 라벨만 사용 |

---

## 10. 다음 단계

1. **모델 검증**
   - 실제 바벨로 인식 테스트
   - 신뢰도 임계값 조정

2. **모델 정확도 개선**
   - 추가 바벨 이미지 수집 (특히 옆면/플레이트)
   - 1000+ 이미지로 확대

3. **VBT 기능 구현**
   - 속도 계산 (픽셀 → 미터 변환)
   - Rep 감지 (변곡점 기반)
   - VBT 지표 표시
