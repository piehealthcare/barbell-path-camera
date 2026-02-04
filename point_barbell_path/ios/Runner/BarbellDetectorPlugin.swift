import Flutter
import CoreML
import Vision

class BarbellDetectorPlugin {
    private var model: VNCoreMLModel?
    private let channel: FlutterMethodChannel

    static func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "barbell_detector",
            binaryMessenger: controller.binaryMessenger
        )
        let instance = BarbellDetectorPlugin(channel: channel)
        channel.setMethodCallHandler(instance.handle)
    }

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        setupModel()
    }

    private func setupModel() {
        // Try compiled .mlmodelc first
        if let modelURL = Bundle.main.url(forResource: "barbell_detector", withExtension: "mlmodelc") {
            do {
                let mlModel = try MLModel(contentsOf: modelURL)
                model = try VNCoreMLModel(for: mlModel)
                print("[BarbellDetector] Loaded compiled model")
                return
            } catch {
                print("[BarbellDetector] Failed to load compiled model: \(error)")
            }
        }

        // Fallback to .mlpackage
        if let packageURL = Bundle.main.url(forResource: "barbell_detector", withExtension: "mlpackage") {
            do {
                let compiledURL = try MLModel.compileModel(at: packageURL)
                let mlModel = try MLModel(contentsOf: compiledURL)
                model = try VNCoreMLModel(for: mlModel)
                print("[BarbellDetector] Loaded and compiled .mlpackage")
            } catch {
                print("[BarbellDetector] Failed to load .mlpackage: \(error)")
            }
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            result(model != nil)
        case "detectBarbell":
            guard let args = call.arguments as? [String: Any],
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int,
                  let planes = args["planes"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            detectBarbell(width: width, height: height, planes: planes, result: result)
        case "dispose":
            model = nil
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
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

        let data = bytes.data
        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferIOSurfacePropertiesKey as String: [:] as [String: Any]
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width, height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            result([])
            return
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        if let baseAddress = CVPixelBufferGetBaseAddress(buffer) {
            let destBytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
            data.withUnsafeBytes { rawBufferPointer in
                guard let srcBaseAddress = rawBufferPointer.baseAddress else { return }
                for row in 0..<height {
                    let srcOffset = row * bytesPerRow
                    let destOffset = row * destBytesPerRow
                    let copyBytes = min(bytesPerRow, destBytesPerRow)
                    memcpy(baseAddress + destOffset, srcBaseAddress + srcOffset, copyBytes)
                }
            }
        }
        CVPixelBufferUnlockBaseAddress(buffer, [])

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                DispatchQueue.main.async { result([]) }
                return
            }

            var detections: [[String: Any]] = []
            for observation in observations {
                let box = observation.boundingBox
                detections.append([
                    "x": box.midX,
                    "y": 1.0 - box.midY,
                    "width": box.width,
                    "height": box.height,
                    "confidence": observation.confidence,
                ])
            }

            DispatchQueue.main.async {
                result(detections)
            }
        }

        request.imageCropAndScaleOption = .scaleFill

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    result([])
                }
            }
        }
    }
}
