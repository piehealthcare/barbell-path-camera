#!/usr/bin/env python3
"""Export barbell detection model to all supported formats.

Usage:
    python export_models.py --weights ../models/pytorch/best.pt

Exports:
    - TFLite (float16) -> ../models/tflite/barbell_detector.tflite
    - CoreML (.mlpackage) -> ../models/coreml/barbell_detector.mlpackage
    - ONNX -> ../models/onnx/barbell_detector.onnx
"""

import argparse
import sys
from pathlib import Path

def export_tflite(model, output_dir: Path):
    """Export to TFLite with float16 quantization."""
    model.export(format='tflite', half=True)
    src = Path(str(model.ckpt_path).replace('.pt', '_saved_model'))
    tflite_file = list(src.rglob('*.tflite'))
    if tflite_file:
        dest = output_dir / 'barbell_detector.tflite'
        import shutil
        shutil.copy2(tflite_file[0], dest)
        print(f'TFLite exported: {dest} ({dest.stat().st_size / 1024 / 1024:.1f} MB)')

def export_coreml(model, output_dir: Path):
    """Export to CoreML .mlpackage format."""
    model.export(format='coreml', nms=True)
    print(f'CoreML exported to: {output_dir}')

def export_onnx(model, output_dir: Path):
    """Export to ONNX format."""
    model.export(format='onnx', simplify=True)
    print(f'ONNX exported to: {output_dir}')

def main():
    parser = argparse.ArgumentParser(description='Export barbell detection model')
    parser.add_argument('--weights', type=str, required=True, help='Path to PyTorch weights (.pt)')
    parser.add_argument('--formats', nargs='+', default=['tflite', 'coreml', 'onnx'],
                        choices=['tflite', 'coreml', 'onnx'], help='Export formats')
    parser.add_argument('--imgsz', type=int, default=640, help='Input image size')
    args = parser.parse_args()

    try:
        from ultralytics import YOLO
    except ImportError:
        print('Error: ultralytics package required. Install with: pip install ultralytics')
        sys.exit(1)

    weights_path = Path(args.weights)
    if not weights_path.exists():
        print(f'Error: weights file not found: {weights_path}')
        sys.exit(1)

    model = YOLO(str(weights_path))
    models_dir = Path(__file__).parent.parent / 'models'

    if 'tflite' in args.formats:
        export_tflite(model, models_dir / 'tflite')

    if 'coreml' in args.formats:
        export_coreml(model, models_dir / 'coreml')

    if 'onnx' in args.formats:
        (models_dir / 'onnx').mkdir(exist_ok=True)
        export_onnx(model, models_dir / 'onnx')

    print('\nExport complete!')

if __name__ == '__main__':
    main()
