# ML Model Setup

## Required Model File

Place your TFLite model here as `barbell_detector.tflite`

## Getting a Barbell Detection Model

### Option 1: Roboflow (Recommended)

1. Go to [Roboflow Universe](https://universe.roboflow.com)
2. Search for "barbell" or "gym equipment" datasets
3. Recommended datasets:
   - "Gym Equipment" by Bangkit Academy (6,620 images)
   - "Barbell Detection" datasets
4. Train a YOLOv8 model or use pre-trained
5. Export as TFLite format:
   - Export → TFLite
   - Select quantization: float16 (recommended for iOS)
6. Download and rename to `barbell_detector.tflite`

### Option 2: Train Custom Model

1. Collect barbell images (100-500 images)
2. Label with bounding boxes around barbell plates
3. Train using:
   - Roboflow (easiest)
   - Google Colab + YOLOv8
   - Ultralytics CLI
4. Export to TFLite

### Option 3: Use Pre-trained COCO Model

For testing purposes, you can use a general object detection model:
1. Download MobileNet SSD from TensorFlow Hub
2. Detect "sports ball" class as proxy for barbell plate
3. Note: Less accurate than custom-trained model

## Model Requirements

- Format: TensorFlow Lite (.tflite)
- Input: 320x320 RGB image (configurable)
- Output: Detection boxes [x, y, width, height, confidence, class]
- Recommended: Float16 quantization for iOS Metal acceleration

## Model Input/Output Specification

```
Input: [1, 320, 320, 3] - float32/float16
Output: [1, N, 6] - [centerX, centerY, width, height, confidence, classId]
```

Values are normalized (0-1 range).
