import Flutter
import UIKit
import CoreML
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var model: VNCoreMLModel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Setup CoreML model
        setupModel()

        // Setup Method Channel
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "barbell_detector", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "detectBarbell" {
                guard let args = call.arguments as? [String: Any],
                      let width = args["width"] as? Int,
                      let height = args["height"] as? Int,
                      let planes = args["planes"] as? [[String: Any]] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                    return
                }

                self?.detectBarbell(width: width, height: height, planes: planes, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupModel() {
        guard let modelURL = Bundle.main.url(forResource: "barbell_detector", withExtension: "mlmodelc") else {
            // Try mlpackage
            if let packageURL = Bundle.main.url(forResource: "barbell_detector", withExtension: "mlpackage") {
                do {
                    let compiledURL = try MLModel.compileModel(at: packageURL)
                    let mlModel = try MLModel(contentsOf: compiledURL)
                    model = try VNCoreMLModel(for: mlModel)
                    print("CoreML model loaded from mlpackage")
                } catch {
                    print("Failed to load mlpackage: \(error)")
                }
            }
            return
        }

        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            model = try VNCoreMLModel(for: mlModel)
            print("CoreML model loaded")
        } catch {
            print("Failed to load model: \(error)")
        }
    }

    private func detectBarbell(width: Int, height: Int, planes: [[String: Any]], result: @escaping FlutterResult) {
        guard let model = model else {
            result([])
            return
        }

        guard let firstPlane = planes.first,
              let bytes = firstPlane["bytes"] as? FlutterStandardTypedData,
              let bytesPerRow = firstPlane["bytesPerRow"] as? Int else {
            result([])
            return
        }

        // Create CVPixelBuffer from bytes
        let data = bytes.data
        var pixelBuffer: CVPixelBuffer?

        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)

        guard let buffer = pixelBuffer else {
            result([])
            return
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let baseAddress = CVPixelBufferGetBaseAddress(buffer)
        data.withUnsafeBytes { ptr in
            memcpy(baseAddress, ptr.baseAddress, min(data.count, bytesPerRow * height))
        }
        CVPixelBufferUnlockBaseAddress(buffer, [])

        // Run Vision request
        let request = VNCoreMLRequest(model: model) { request, error in
            var detections: [[String: Any]] = []

            if let results = request.results as? [VNRecognizedObjectObservation] {
                for observation in results {
                    let box = observation.boundingBox
                    // Convert from Vision coordinates (bottom-left origin) to normalized (top-left origin)
                    let detection: [String: Any] = [
                        "x": box.midX,
                        "y": 1.0 - box.midY,
                        "width": box.width,
                        "height": box.height,
                        "confidence": observation.confidence
                    ]
                    detections.append(detection)
                }
            }

            DispatchQueue.main.async {
                result(detections)
            }
        }

        request.imageCropAndScaleOption = .scaleFill

        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Vision request failed: \(error)")
                DispatchQueue.main.async {
                    result([])
                }
            }
        }
    }
}
