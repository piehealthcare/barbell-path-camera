#!/bin/bash
# Copy model files to target app project.
#
# Usage:
#   ./copy_to_app.sh <target_app_path>
#
# Example:
#   ./copy_to_app.sh ../../point_barbell_path

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODELS_DIR="$SCRIPT_DIR/../models"
TARGET_APP="${1:?Usage: $0 <target_app_path>}"

echo "Copying models to: $TARGET_APP"

# TFLite -> Android assets
ANDROID_ASSETS="$TARGET_APP/android/app/src/main/assets"
mkdir -p "$ANDROID_ASSETS"
cp "$MODELS_DIR/tflite/barbell_detector.tflite" "$ANDROID_ASSETS/"
echo "  TFLite -> $ANDROID_ASSETS/barbell_detector.tflite"

# CoreML -> iOS Runner
IOS_RUNNER="$TARGET_APP/ios/Runner"
if [ -d "$MODELS_DIR/coreml/barbell_detector.mlpackage" ]; then
    cp -r "$MODELS_DIR/coreml/barbell_detector.mlpackage" "$IOS_RUNNER/"
    echo "  CoreML -> $IOS_RUNNER/barbell_detector.mlpackage"
else
    echo "  Warning: CoreML model not found, skipping iOS"
fi

echo "Done!"
