import Flutter
import AVFoundation
import CoreVideo
import CoreGraphics

class VideoCompositorPlugin {
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var isRecording = false
    private var frameCount: Int64 = 0
    private var fps: Int32 = 30
    private let channel: FlutterMethodChannel

    static func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "video_compositor",
            binaryMessenger: controller.binaryMessenger
        )
        let instance = VideoCompositorPlugin(channel: channel)
        channel.setMethodCallHandler(instance.handle)
    }

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startRecording":
            guard let args = call.arguments as? [String: Any],
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int,
                  let fps = args["fps"] as? Int,
                  let bitrate = args["bitrate"] as? Int else {
                result(false)
                return
            }
            startRecording(width: width, height: height, fps: fps, bitrate: bitrate, result: result)
        case "addFrame":
            guard let args = call.arguments as? [String: Any],
                  let cameraFrame = args["cameraFrame"] as? FlutterStandardTypedData,
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int else {
                result(nil)
                return
            }
            let overlayPng = args["overlayPng"] as? FlutterStandardTypedData
            addFrame(cameraFrame: cameraFrame.data, overlayPng: overlayPng?.data, width: width, height: height, result: result)
        case "stopRecording":
            stopRecording(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startRecording(width: Int, height: Int, fps: Int, bitrate: Int, result: @escaping FlutterResult) {
        self.fps = Int32(fps)
        frameCount = 0

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("point_barbell_\(Int(Date().timeIntervalSince1970)).mp4")

        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: bitrate,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                ],
            ]

            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoInput?.expectsMediaDataInRealTime = true

            let sourcePixelAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
            ]

            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoInput!,
                sourcePixelBufferAttributes: sourcePixelAttributes
            )

            if assetWriter!.canAdd(videoInput!) {
                assetWriter!.add(videoInput!)
            }

            assetWriter!.startWriting()
            assetWriter!.startSession(atSourceTime: .zero)

            isRecording = true
            result(true)
        } catch {
            print("[VideoCompositor] Failed to start recording: \(error)")
            result(false)
        }
    }

    private func addFrame(cameraFrame: Data, overlayPng: Data?, width: Int, height: Int, result: @escaping FlutterResult) {
        guard isRecording,
              let videoInput = videoInput,
              videoInput.isReadyForMoreMediaData,
              let pixelBufferAdaptor = pixelBufferAdaptor else {
            result(nil)
            return
        }

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferAdaptor.pixelBufferPool!, &pixelBuffer)

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            result(nil)
            return
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        // Copy camera frame
        if let baseAddress = CVPixelBufferGetBaseAddress(buffer) {
            let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
            cameraFrame.withUnsafeBytes { rawBufferPointer in
                guard let srcBaseAddress = rawBufferPointer.baseAddress else { return }
                let copySize = min(cameraFrame.count, bytesPerRow * height)
                memcpy(baseAddress, srcBaseAddress, copySize)
            }
        }

        // Composite overlay if present
        if let overlayData = overlayPng,
           let overlayImage = UIImage(data: overlayData)?.cgImage {
            let context = CGContext(
                data: CVPixelBufferGetBaseAddress(buffer),
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
            )
            context?.draw(overlayImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        let presentationTime = CMTime(value: frameCount, timescale: fps)
        pixelBufferAdaptor.append(buffer, withPresentationTime: presentationTime)
        frameCount += 1

        result(nil)
    }

    private func stopRecording(result: @escaping FlutterResult) {
        guard isRecording, let assetWriter = assetWriter else {
            result(nil)
            return
        }

        isRecording = false
        videoInput?.markAsFinished()

        let outputURL = assetWriter.outputURL
        assetWriter.finishWriting {
            DispatchQueue.main.async {
                result(outputURL.path)
            }
        }
    }
}
