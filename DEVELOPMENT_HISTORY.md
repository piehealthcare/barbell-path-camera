# Barbell Path Camera 개발 히스토리

## 프로젝트 개요

실시간 바벨 경로 추적 Flutter 모듈. 마커 없이 순수 컴퓨터 비전으로 바벨 끝단(플레이트)을 감지하고 경로를 추적함.

## 개발 일자
2026-01-24

---

## 1. 완료된 작업

### 1.1 카메라 기능 구현
- Flutter `camera` 패키지 기반 실시간 카메라 프리뷰
- 카메라 방향/비율 문제 수정 완료
- 후면 카메라 자동 선택

### 1.2 YOLOv8 바벨 감지 모델 학습
- **데이터셋**: Roboflow `barbell-object-detection` (261 train / 25 val 이미지)
- **모델**: YOLOv8 nano (3M parameters)
- **학습 설정**:
  ```python
  model = YOLO('yolov8n.pt')
  results = model.train(
      data='./barbell_dataset/data.yaml',
      epochs=50,
      imgsz=320,
      batch=16,
      patience=10,
      device='mps',  # Apple M3 Pro GPU
  )
  ```
- **결과**: mAP50 = 0.948 (24 epochs에서 early stopping)

### 1.3 모델 Export
- **TFLite**: `best_float16.tflite` (6MB) - Android용
- **CoreML**: `best.mlpackage` (6MB) - iOS용
- **위치**: `barbell_tracking/assets/ml/barbell_detector.tflite`

### 1.4 Flutter 앱 구현
- ultralytics_yolo 패키지 통합
- YOLOView 위젯 기반 실시간 감지
- 패스 궤적 시각화 (CustomPainter)

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
└── training/                   # 모델 학습
    ├── barbell_dataset/
    │   ├── train/images/
    │   ├── valid/images/
    │   └── data.yaml
    ├── runs/detect/barbell_detector/
    │   └── weights/
    │       ├── best.pt
    │       ├── best.mlpackage/
    │       └── tflite_output/
    └── train_barbell_detector.ipynb
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

### 4.2 알려진 문제
- [x] ultralytics_yolo iOS 실행 테스트 - v0.1.46 사용 (v0.2.0 Swift 에러)
- [ ] 모델이 모든 객체를 바벨로 인식하는 문제 (신뢰도 임계값 조정 필요)
- [x] CoreML 모델을 iOS 프로젝트에 추가 완료 (`example/ios/Runner/barbell_detector.mlpackage`)

### 4.3 데이터셋 한계
- 현재 데이터셋: 208장 (상대적으로 작음)
- 권장: 500+ 이미지로 추가 학습

---

## 5. iOS 모델 배포 방법

### CoreML 모델 추가
1. Xcode에서 `example/ios/Runner.xcodeproj` 열기
2. `best.mlpackage`를 Runner 타겟으로 드래그
3. "Copy items if needed" 체크
4. Target Membership에서 Runner 체크

### 모델 경로
- iOS: `barbell_detector.mlpackage` (CoreML)
- Android: `android/app/src/main/assets/barbell_detector.tflite`

---

## 6. 참고 자료

### 관련 GitHub 저장소
- [NeythonLecStreitz/BarbellTrackingCode](https://github.com/NeythonLecStreitz/BarbellTrackingCode) - AruCo 마커 기반
- [Marticles/barbell-path-tracker](https://github.com/Marticles/barbell-path-tracker) - 수동 ROI 선택 + 전통적 추적 알고리즘

### Flutter ML 패키지
- [ultralytics_yolo](https://pub.dev/packages/ultralytics_yolo) - 공식 Ultralytics Flutter 플러그인
- [flutter_vision](https://pub.dev/packages/flutter_vision) - YOLO 지원 (iOS 미완성)

### Roboflow 데이터셋
- [barbell-object-detection](https://universe.roboflow.com/gym-pal/barbell-object-detection)
- [Barbells Detector](https://universe.roboflow.com/yolo-project-c2bfs/barbells-detector)

---

## 7. 다음 단계

1. **iOS 모델 통합 테스트**
   - CoreML 모델을 Xcode 프로젝트에 추가
   - 실제 디바이스에서 테스트

2. **모델 정확도 개선**
   - 추가 바벨 이미지 수집 (특히 옆면/플레이트)
   - 신뢰도 임계값 조정 (현재 0.5)

3. **VBT 기능 구현**
   - 속도 계산 (픽셀 → 미터 변환)
   - Rep 감지 (변곡점 기반)
   - VBT 지표 표시

---

## 8. API 키 정보

### Roboflow
- API Key: `JrZhEA1eserEsM6xkLD3` (사용자 제공)
- Workspace: `gym-pal`
- Project: `barbell-object-detection`

---

## 9. 주요 코드 참조

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
  modelPath: 'barbell_detector',
  task: YOLOTask.detect,
  onResult: (results) {
    // 감지 결과 처리
  },
)
```

---

## 10. 명령어 모음

### 모델 학습
```bash
cd training
python3 -c "
from ultralytics import YOLO
model = YOLO('yolov8n.pt')
model.train(data='./barbell_dataset/data.yaml', epochs=50, imgsz=320)
"
```

### Flutter 빌드
```bash
cd example
flutter pub get
flutter run -d "Tommy"  # iPhone
```

### TFLite Export
```bash
python3 -c "
from ultralytics import YOLO
model = YOLO('runs/detect/barbell_detector/weights/best.pt')
model.export(format='tflite', imgsz=320)
"
```
