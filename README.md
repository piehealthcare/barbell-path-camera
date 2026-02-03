# Barbell Path Camera

YOLOv8 기반 실시간 바벨 궤적 추적 및 VBT(Velocity Based Training) 분석 시스템.

카메라로 바벨 엔드포인트를 감지하고, ByteTracker + Kalman Filter로 궤적을 추적하며, 속도/가속도/ROM 등을 실시간 분석합니다.

---

## 프로젝트 구조

```
barbell_path_camera/
├── barbell_tracking/        # 핵심 Flutter 패키지 (추적 알고리즘, 분석, UI)
├── barbell_ml_models/       # ML 모델 파일 및 인터페이스
├── example/                 # 데모 앱 (barbell_tracking 사용 예시)
├── point_barbell_path/      # 프로덕션 앱 (PoinT 바벨패스)
└── training/                # YOLO 모델 학습 스크립트
```

### 패키지 의존 관계

```
point_barbell_path (프로덕션 앱)
├── barbell_tracking (핵심 알고리즘)
└── barbell_ml_models (모델 설정/인터페이스)

example (데모 앱)
└── barbell_tracking (핵심 알고리즘)
```

---

## 빠른 시작

### 1. barbell_tracking 패키지 추가

```yaml
# pubspec.yaml
dependencies:
  barbell_tracking:
    path: ../barbell_tracking
  barbell_ml_models:
    path: ../barbell_ml_models
```

### 2. 기본 사용법

```dart
import 'package:barbell_tracking/barbell_tracking.dart';

// 트래커 초기화
final tracker = BarbellTrackingService(
  config: BarbellTrackingConfig(
    exerciseType: ExerciseType.benchPress,
    highConfThreshold: 0.6,
    lowConfThreshold: 0.1,
    smoothingWindow: 3,
  ),
);

// 프레임마다 감지 결과 전달
final result = tracker.processDetections(detections);

// 결과 활용
if (result != null) {
  print('위치: (${result.x}, ${result.y})');
  print('속도: ${result.speedMps} m/s');
  print('존: ${result.velocityZone}');
  print('렙 수: ${result.exerciseStats?.repCount}');
}
```

---

## 핵심 아키텍처

### 데이터 파이프라인

```
카메라 프레임
    ↓
네이티브 ML 추론 (iOS: CoreML / Android: TFLite)
    ↓  MethodChannel('barbell_detector')
Detection 객체 (정규화 좌표 0~1)
    ↓
ByteTracker (Kalman Filter + IoU/거리 매칭)
    ↓
PathSmoother (이동평균 + 이상치 제거)
    ↓
ExerciseAnalyzer (렙 감지, 속도/ROM 분석)
    ↓
UI 오버레이 (궤적, VBT 존, 통계)
```

---

## barbell_tracking 패키지 상세

### ByteTracker (`lib/src/tracker/byte_tracker.dart`)

ByteTrack 알고리즘 기반 단일 객체 추적기. 높은/낮은 confidence 감지를 분리하여 매칭 정확도를 높입니다.

**동작 원리:**

1. 감지 결과를 confidence 기준으로 분리
   - 높은 confidence (>= 0.6): 우선 매칭
   - 낮은 confidence (>= 0.1): 복구용 매칭
2. IoU >= 0.3 또는 유클리드 거리 <= 0.15 이면 매칭 성공
3. 매칭 실패 시 Kalman Filter로 위치 예측 (최대 15 프레임)
4. 30 프레임 이상 미감지 시 트랙 제거

**주요 파라미터:**

| 파라미터 | 기본값 | 설명 |
|---------|-------|------|
| `highConfThreshold` | 0.6 | 높은 confidence 기준 |
| `lowConfThreshold` | 0.1 | 낮은 confidence 기준 |
| `maxPredictionFrames` | 15 | Kalman 예측 최대 프레임 |
| `maxPathLength` | 500 | 경로 포인트 최대 개수 |
| `predictionConfidenceDecay` | 0.9 | 예측 시 confidence 감쇠율 |

**듀얼 트래커 패턴:**

실제 앱에서는 바벨 양쪽 엔드포인트를 각각 추적합니다:

```dart
final leftTracker = ByteTracker(config: config);
final rightTracker = ByteTracker(config: config);

// 감지 결과를 X좌표 기준으로 정렬
detections.sort((a, b) => a.cx.compareTo(b.cx));

// 좌측 → leftTracker, 우측 → rightTracker
leftTracker.update([detections.first]);
rightTracker.update([detections.last]);
```

### Kalman Filter (`lib/src/tracker/kalman_filter.dart`)

등속 모델 기반 2D Kalman Filter. 상태 벡터 `[x, y, vx, vy]`.

```dart
final kf = KalmanFilter2D(
  dt: 1 / 30,              // 30fps
  processNoise: 0.01,       // 프로세스 노이즈
  measurementNoise: 0.1,    // 측정 노이즈
);

kf.predict();              // 다음 위치 예측
kf.update(measuredX, measuredY);  // 측정값으로 보정
```

### PathSmoother (`lib/src/tracker/path_smoother.dart`)

이동평균 기반 경로 스무딩.

| 파라미터 | 기본값 | 설명 |
|---------|-------|------|
| `windowSize` | 3 | 이동평균 윈도우 크기 |
| `outlierThreshold` | 0.15 | 이상치 제거 임계값 |
| `minMovementThreshold` | 0.002 | 최소 이동 임계값 (노이즈 필터) |

### ExerciseAnalyzer (`lib/src/analysis/exercise_analyzer.dart`)

Y축 움직임 기반 렙 감지 및 운동 분석.

**렙 감지 로직:**
```
idle → descending (하강) → ascending (상승) → idle/atTop = 1 렙 완료
```

**분석 항목:**
- `repCount`: 현재 렙 수
- `currentPhase`: 현재 움직임 단계 (idle, descending, ascending, atBottom, atTop)
- `currentROM`: 현재 가동범위 (cm)
- `currentSpeed`: 현재 속도 (m/s)
- `currentAcceleration`: 현재 가속도 (m/s²)
- `pathDeviation`: 경로 편차 (이상적 직선 대비)

**렙 상세 정보 (RepInfo):**
- 소요 시간, ROM, 평균/최고 속도
- 편심/구심 시간, 템포 비율
- 경로 편차

**세트 정보 (SetInfo):**
- 렙별 속도 추이, 속도 손실률 계산

### VBT Zones (`lib/src/analysis/vbt_zones.dart`)

속도 기반 트레이닝 존 분류:

| 존 | 속도 범위 | 색상 | 훈련 목표 |
|----|----------|------|---------|
| Strength | < 0.5 m/s | 빨강 | 최대 근력 |
| Strength-Speed | 0.5 - 0.75 m/s | 주황 | 근력+스피드 |
| Power | 0.75 - 1.0 m/s | 노랑 | 파워 |
| Speed-Strength | 1.0 - 1.3 m/s | 초록 | 스피드+근력 |
| Speed | > 1.3 m/s | 파랑 | 스피드 |

**프리셋:**

```dart
// 목적별 프리셋
VbtConfig.strengthPreset()  // 목표: Strength 존
VbtConfig.powerPreset()     // 목표: Power 존
VbtConfig.speedPreset()     // 목표: Speed 존
```

### ScaleConfig (`lib/src/scale/scale_config.dart`)

정규화 좌표(0~1)를 실제 단위(m/s, cm)로 변환.

**캘리브레이션 방법:**

```dart
// 1. 플레이트 크기 기반
ScaleConfig.fromPlateSize(
  platePixels: 100,          // 플레이트 픽셀 크기
  plateWeight: PlateWeight.kg20,  // 20kg = 직경 45cm
  imageHeight: 1920,
);

// 2. 거리 기반
ScaleConfig.fromDistance(
  knownDistancePixels: 200,
  knownDistanceMeters: 1.0,
  imageHeight: 1920,
);

// 3. 운동별 프리셋
ScaleConfig.presetForExercise(ExerciseType.squat);     // 시야 2.5m
ScaleConfig.presetForExercise(ExerciseType.benchPress); // 시야 2.0m
```

### UI 컴포넌트 (`lib/src/ui/`)

**BarbellPathOverlay**: 속도 기반 색상 궤적 오버레이

```dart
BarbellPathOverlay(
  path: trackResult.path,
  scaleConfig: scaleConfig,
  showCurrentPosition: true,
)
```

**VbtZoneLegend**: VBT 존 범례

```dart
VbtZoneLegend(
  direction: Axis.horizontal,  // 또는 Axis.vertical
  currentZone: VelocityZone.power,
)
```

**VelocityZoneIndicator**: 현재 속도 존 표시 (글로우 효과)

---

## 네이티브 ML 플러그인

### iOS (CoreML)

`BarbellDetectorPlugin.swift` - Vision 프레임워크 + CoreML 사용.

**설정:**
1. `barbell_detector.mlpackage`를 Xcode 프로젝트에 추가
2. `AppDelegate.swift`에서 플러그인 등록:

```swift
let controller = window?.rootViewController as! FlutterViewController
BarbellDetectorPlugin.register(with: controller.registrar(forPlugin: "BarbellDetectorPlugin")!)
```

**동작:**
- 카메라 프레임(바이트) → CVPixelBuffer(32BGRA) 변환
- VNCoreMLRequest로 추론 실행 (백그라운드 큐)
- Y축 반전하여 Flutter 좌표계에 맞춤 (`1.0 - box.midY`)
- 결과를 메인 스레드에서 반환

### Android (TFLite)

`BarbellDetectorPlugin.kt` - TFLite Interpreter 사용.

**설정:**
1. `barbell_detector.tflite`를 `android/app/src/main/assets/`에 배치
2. `MainActivity.kt`에서 플러그인 등록:

```kotlin
BarbellDetectorPlugin.register(this, flutterEngine.dartExecutor.binaryMessenger, applicationContext)
```

**동작:**
- YUV_420_888 또는 BGRA 입력 지원
- 640x640 리사이즈, [0,1] 정규화
- YOLOv8 출력 파싱: `[1, 4+numClasses, 8400]` 텐서
- Greedy NMS 적용 (IoU > 0.45 억제)

### Flutter에서 호출

```dart
final channel = MethodChannel('barbell_detector');

// 초기화
await channel.invokeMethod('initialize');

// 감지 실행
final results = await channel.invokeMethod('detectBarbell', {
  'planes': [
    {
      'bytes': plane.bytes,
      'bytesPerRow': plane.bytesPerRow,
      'bytesPerPixel': plane.bytesPerPixel,
    }
  ],
  'width': image.width,
  'height': image.height,
  'rotation': 90,
});
```

---

## UI 커스터마이징

### 궤적 색상 변경

궤적은 VBT 존 기반으로 자동 색상이 적용됩니다. 커스텀 색상을 사용하려면 `BarbellPathPainter`를 참조하여 `CustomPainter`를 직접 구현하세요:

```dart
// VBT 존별 기본 색상
VelocityZone.strength       → Colors.red
VelocityZone.strengthSpeed  → Colors.orange
VelocityZone.power          → Colors.yellow
VelocityZone.speedStrength  → Colors.green
VelocityZone.speed          → Colors.blue
```

### 통계 패널 커스터마이징

`ExerciseStats`에서 제공하는 데이터로 자유롭게 UI를 구성할 수 있습니다:

```dart
final stats = trackResult.exerciseStats;

// 사용 가능한 데이터
stats.repCount          // 렙 수
stats.currentPhase      // 현재 단계 (MovementPhase)
stats.currentROM        // ROM (cm)
stats.currentSpeed      // 속도 (m/s)
stats.currentAcceleration // 가속도 (m/s²)
stats.pathDeviation     // 경로 편차
stats.reps              // List<RepInfo> - 렙별 상세
stats.sets              // List<SetInfo> - 세트별 상세
```

### 운동 타입 추가

```dart
// 기본 제공 운동
ExerciseType.squat
ExerciseType.benchPress
ExerciseType.deadlift
ExerciseType.overheadPress
ExerciseType.custom

// 커스텀 설정으로 사용
final config = BarbellTrackingConfig(
  exerciseType: ExerciseType.custom,
  minRepAmplitude: 0.05,  // 렙 감지 민감도 조절
);
```

### 프레임 스킵 (성능 튜닝)

모든 프레임을 처리하면 부하가 큽니다. 프레임 스킵으로 성능을 조절하세요:

```dart
int frameSkip = 2;  // 3프레임당 1회 처리
int frameCount = 0;

void onCameraFrame(CameraImage image) {
  frameCount++;
  if (frameCount % (frameSkip + 1) != 0) return;
  // 여기서 감지 실행
}
```

---

## ML 모델

### 현재 모델 성능

| 항목 | 값 |
|------|-----|
| 아키텍처 | YOLOv8s |
| 입력 크기 | 640 x 640 |
| 클래스 | `barbell_endpoint`, `barbell_collar` |
| mAP50 | 98.09% |
| mAP50-95 | 82.05% |
| Precision | 95.31% |
| Recall | 93.06% |

### 모델 파일 위치

```
barbell_ml_models/models/
├── coreml/barbell_detector.mlpackage   # iOS용 (21MB)
├── pytorch/best.pt                      # PyTorch 원본 (22MB)
└── tflite/barbell_detector.tflite       # Android용 (6MB)
```

### 모델 재학습

```bash
cd training/

# 데이터 증강 (18배)
python3 augment_data.py

# 파인튜닝 (기존 모델 기반)
python3 finetune_model.py

# YOLOv8s로 업그레이드 학습
python3 finetune_model.py --upgrade

# 고해상도 학습 (1280px)
python3 finetune_model.py --hires
```

### 증강 기법

`augment_data.py`가 적용하는 18가지 증강:
밝기 조절, 어둡게, 수평 뒤집기, 모션 블러 (약/중/강/극강), 컬러 지터, 가우시안 노이즈, 컷아웃, 줌 블러, 더블 블러, 각 조합

---

## 다국어 지원

point_barbell_path 앱은 9개 언어를 지원합니다:

한국어(ko), 영어(en), 일본어(ja), 중국어(zh), 독일어(de), 스페인어(es), 프랑스어(fr), 이탈리아어(it), 포르투갈어(pt)

번역 파일 위치: `point_barbell_path/lib/core/l10n/`

---

## 개발 환경

- Flutter SDK >= 3.24.0
- Xcode (iOS 빌드)
- Android Studio (Android 빌드)
- Python 3.9+ (모델 학습)
- ultralytics (YOLO 학습 프레임워크)

## 라이선스

Private repository - PieHealthcare
