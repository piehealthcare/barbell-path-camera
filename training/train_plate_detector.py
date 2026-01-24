#!/usr/bin/env python3
"""
바벨 플레이트 끝단 감지 모델 학습
"""

from pathlib import Path
import shutil

TRAINING_DIR = Path(__file__).parent

def train():
    from ultralytics import YOLO

    data_yaml = TRAINING_DIR / "barbell_plate_dataset" / "data.yaml"

    print("=== YOLOv8 바벨 플레이트 감지 모델 학습 ===")
    print(f"데이터셋: {data_yaml}")

    model = YOLO("yolov8n.pt")

    results = model.train(
        data=str(data_yaml),
        epochs=100,
        imgsz=320,
        batch=16,
        name="barbell_plate_detector",
        patience=20,
        device="mps",  # Apple Silicon (없으면 "cpu"로 변경)
        workers=4,
        # Augmentation
        hsv_h=0.015,
        hsv_s=0.7,
        hsv_v=0.4,
        degrees=10,
        translate=0.1,
        scale=0.5,
        flipud=0.5,
        fliplr=0.5,
        mosaic=1.0,
    )

    print("\n=== 학습 완료 ===")
    return model

def export_and_copy(model):
    """모델 Export 및 앱으로 복사"""
    print("\n=== 모델 Export ===")

    if model is None:
        from ultralytics import YOLO
        best_model_path = TRAINING_DIR / "runs" / "detect" / "barbell_plate_detector" / "weights" / "best.pt"
        model = YOLO(str(best_model_path))

    # CoreML export (iOS)
    print("CoreML 모델 생성 중...")
    model.export(format="coreml", imgsz=320, half=True, nms=True)

    # TFLite export (Android)
    print("TFLite 모델 생성 중...")
    model.export(format="tflite", imgsz=320, half=True)

    # 앱으로 복사
    runs_dir = TRAINING_DIR / "runs" / "detect" / "barbell_plate_detector" / "weights"

    # CoreML
    coreml_src = runs_dir / "best.mlpackage"
    coreml_dst = TRAINING_DIR.parent / "example" / "ios" / "Runner" / "barbell_detector.mlpackage"
    if coreml_src.exists():
        if coreml_dst.exists():
            shutil.rmtree(coreml_dst)
        shutil.copytree(coreml_src, coreml_dst)
        print(f"  CoreML 복사: {coreml_dst}")

    # TFLite
    tflite_src = runs_dir / "best_float16.tflite"
    tflite_dst = TRAINING_DIR.parent / "barbell_tracking" / "assets" / "ml" / "barbell_detector.tflite"
    if tflite_src.exists():
        shutil.copy2(tflite_src, tflite_dst)
        print(f"  TFLite 복사: {tflite_dst}")

    print("\n=== Export 완료 ===")

if __name__ == "__main__":
    model = train()
    export_and_copy(model)
