package com.point.point_barbell_path

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register barbell detector with context for asset access
        val detectorChannel = io.flutter.plugin.common.MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "barbell_detector"
        )
        detectorChannel.setMethodCallHandler(BarbellDetectorPlugin(this))

        // Register video compositor
        VideoCompositorPlugin.registerWith(flutterEngine)
    }
}
