package com.point.point_barbell_path

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel
import kotlin.math.max
import kotlin.math.min

class BarbellDetectorPlugin(private val context: Context) : MethodChannel.MethodCallHandler {
    private var interpreter: Interpreter? = null
    private val inputSize = 640
    private val numClasses = 2
    private val numDetections = 8400
    private val confidenceThreshold = 0.25f
    private val iouThreshold = 0.45f

    /** Internal detection representation for NMS processing. */
    private data class RawDetection(
        val x: Float,           // center x, normalized 0..1
        val y: Float,           // center y, normalized 0..1
        val width: Float,       // width, normalized 0..1
        val height: Float,      // height, normalized 0..1
        val confidence: Float
    )

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "detectBarbell" -> {
                val width = call.argument<Int>("width") ?: 0
                val height = call.argument<Int>("height") ?: 0
                val planes = call.argument<List<Map<String, Any>>>("planes") ?: emptyList()
                detectBarbell(width, height, planes, result)
            }
            "dispose" -> {
                interpreter?.close()
                interpreter = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun initialize(result: MethodChannel.Result) {
        try {
            val modelBuffer = loadModelFile("barbell_detector.tflite")
            if (modelBuffer != null) {
                val options = Interpreter.Options().apply {
                    setNumThreads(4)
                }
                interpreter = Interpreter(modelBuffer, options)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun loadModelFile(filename: String): MappedByteBuffer? {
        return try {
            val assetFileDescriptor = context.assets.openFd(filename)
            val inputStream = FileInputStream(assetFileDescriptor.fileDescriptor)
            val fileChannel = inputStream.channel
            val startOffset = assetFileDescriptor.startOffset
            val declaredLength = assetFileDescriptor.declaredLength
            fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
        } catch (e: Exception) {
            null
        }
    }

    private fun detectBarbell(
        width: Int,
        height: Int,
        planes: List<Map<String, Any>>,
        result: MethodChannel.Result
    ) {
        if (interpreter == null) {
            result.success(emptyList<Map<String, Any>>())
            return
        }

        try {
            // Step 1: Convert camera frame to RGB and resize to 640x640 float tensor
            val inputBuffer = preprocessFrame(width, height, planes)
            if (inputBuffer == null) {
                result.success(emptyList<Map<String, Any>>())
                return
            }

            // Step 2: Prepare output buffer - YOLOv8 output shape [1, 4+numClasses, 8400]
            val outputArray = Array(1) { Array(4 + numClasses) { FloatArray(numDetections) } }

            // Step 3: Run inference
            interpreter!!.run(inputBuffer, outputArray)

            // Step 4: Parse output and apply NMS
            val detections = postprocess(outputArray[0])

            result.success(detections)
        } catch (e: Exception) {
            result.success(emptyList<Map<String, Any>>())
        }
    }

    // -------------------------------------------------------------------------
    // Preprocessing: camera frame -> 640x640 RGB float tensor
    // -------------------------------------------------------------------------

    /**
     * Converts camera frame bytes to a 640x640 RGB float input tensor.
     *
     * Android camera plugin sends YUV_420_888 format with 3 planes:
     *   plane[0] = Y (luminance), plane[1] = U (Cb), plane[2] = V (Cr)
     *
     * Falls back to BGRA single-plane handling if only 1 plane is provided.
     */
    private fun preprocessFrame(
        width: Int,
        height: Int,
        planes: List<Map<String, Any>>
    ): ByteBuffer? {
        if (planes.isEmpty()) return null

        // Allocate float input buffer: 1 x 640 x 640 x 3 (NHWC, float32)
        val inputBuffer = ByteBuffer.allocateDirect(inputSize * inputSize * 3 * 4)
        inputBuffer.order(ByteOrder.nativeOrder())

        if (planes.size >= 3) {
            // YUV_420_888 format (standard Android camera)
            preprocessYUV(width, height, planes, inputBuffer)
        } else {
            // Single plane - BGRA8888 format (fallback)
            preprocessBGRA(width, height, planes[0], inputBuffer)
        }

        return inputBuffer
    }

    /**
     * Preprocesses YUV_420_888 camera data into the model input tensor.
     * Performs nearest-neighbor resize from source dimensions to 640x640
     * with YUV->RGB color space conversion and normalization to [0, 1].
     */
    private fun preprocessYUV(
        width: Int,
        height: Int,
        planes: List<Map<String, Any>>,
        inputBuffer: ByteBuffer
    ) {
        val yBytes = planes[0]["bytes"] as? ByteArray ?: return
        val uBytes = planes[1]["bytes"] as? ByteArray ?: return
        val vBytes = planes[2]["bytes"] as? ByteArray ?: return

        val yRowStride = (planes[0]["bytesPerRow"] as? Number)?.toInt() ?: width
        val uvRowStride = (planes[1]["bytesPerRow"] as? Number)?.toInt() ?: (width / 2)
        val uvPixelStride = (planes[1]["bytesPerPixel"] as? Number)?.toInt() ?: 1

        val scaleX = width.toFloat() / inputSize
        val scaleY = height.toFloat() / inputSize

        inputBuffer.rewind()

        for (dy in 0 until inputSize) {
            for (dx in 0 until inputSize) {
                // Map destination pixel back to source coordinates (nearest-neighbor)
                val srcX = (dx * scaleX).toInt().coerceIn(0, width - 1)
                val srcY = (dy * scaleY).toInt().coerceIn(0, height - 1)

                // Read Y value
                val yIndex = srcY * yRowStride + srcX
                val y = (yBytes[yIndex.coerceIn(0, yBytes.size - 1)].toInt() and 0xFF).toFloat()

                // Read U, V values (chroma is subsampled by 2 in both dimensions)
                val uvX = srcX / 2
                val uvY = srcY / 2
                val uIndex = uvY * uvRowStride + uvX * uvPixelStride
                val vIndex = uvY * uvRowStride + uvX * uvPixelStride

                val u = (uBytes[uIndex.coerceIn(0, uBytes.size - 1)].toInt() and 0xFF).toFloat() - 128f
                val v = (vBytes[vIndex.coerceIn(0, vBytes.size - 1)].toInt() and 0xFF).toFloat() - 128f

                // YUV to RGB conversion (BT.601)
                val r = (y + 1.402f * v).coerceIn(0f, 255f)
                val g = (y - 0.344136f * u - 0.714136f * v).coerceIn(0f, 255f)
                val b = (y + 1.772f * u).coerceIn(0f, 255f)

                // Normalize to [0, 1]
                inputBuffer.putFloat(r / 255f)
                inputBuffer.putFloat(g / 255f)
                inputBuffer.putFloat(b / 255f)
            }
        }
    }

    /**
     * Preprocesses BGRA8888 camera data into the model input tensor.
     * Used as fallback when only a single plane is provided.
     */
    private fun preprocessBGRA(
        width: Int,
        height: Int,
        plane: Map<String, Any>,
        inputBuffer: ByteBuffer
    ) {
        val bytes = plane["bytes"] as? ByteArray ?: return
        val bytesPerRow = (plane["bytesPerRow"] as? Number)?.toInt() ?: (width * 4)

        val scaleX = width.toFloat() / inputSize
        val scaleY = height.toFloat() / inputSize

        inputBuffer.rewind()

        for (dy in 0 until inputSize) {
            for (dx in 0 until inputSize) {
                val srcX = (dx * scaleX).toInt().coerceIn(0, width - 1)
                val srcY = (dy * scaleY).toInt().coerceIn(0, height - 1)

                val pixelIndex = srcY * bytesPerRow + srcX * 4
                if (pixelIndex + 2 >= bytes.size) {
                    inputBuffer.putFloat(0f)
                    inputBuffer.putFloat(0f)
                    inputBuffer.putFloat(0f)
                    continue
                }

                // BGRA -> RGB
                val b = (bytes[pixelIndex].toInt() and 0xFF).toFloat()
                val g = (bytes[pixelIndex + 1].toInt() and 0xFF).toFloat()
                val r = (bytes[pixelIndex + 2].toInt() and 0xFF).toFloat()

                // Normalize to [0, 1]
                inputBuffer.putFloat(r / 255f)
                inputBuffer.putFloat(g / 255f)
                inputBuffer.putFloat(b / 255f)
            }
        }
    }

    // -------------------------------------------------------------------------
    // Postprocessing: YOLOv8 output tensor -> NMS-filtered detections
    // -------------------------------------------------------------------------

    /**
     * Parses the YOLOv8 output tensor [5, 8400] and applies NMS.
     *
     * The output layout (transposed from standard [8400, 5]):
     *   row 0: center x (in pixels, 0..640)
     *   row 1: center y (in pixels, 0..640)
     *   row 2: box width (in pixels)
     *   row 3: box height (in pixels)
     *   row 4: confidence score (single class)
     *
     * Returns a List<Map> with normalized (0..1) coordinates matching the
     * Detection class on the Dart side.
     */
    private fun postprocess(output: Array<FloatArray>): List<Map<String, Any>> {
        // Collect all detections above confidence threshold
        val candidates = mutableListOf<RawDetection>()
        for (i in 0 until numDetections) {
            // Find max class confidence across all classes (rows 4..4+numClasses-1)
            var maxConf = 0f
            for (c in 0 until numClasses) {
                val conf = output[4 + c][i]
                if (conf > maxConf) maxConf = conf
            }
            if (maxConf < confidenceThreshold) continue

            val cx = output[0][i] / inputSize  // normalize to 0..1
            val cy = output[1][i] / inputSize
            val w  = output[2][i] / inputSize
            val h  = output[3][i] / inputSize

            // Sanity check - skip degenerate boxes
            if (w <= 0f || h <= 0f || w > 1f || h > 1f) continue
            if (cx < 0f || cx > 1f || cy < 0f || cy > 1f) continue

            candidates.add(RawDetection(cx, cy, w, h, maxConf))
        }

        if (candidates.isEmpty()) return emptyList()

        // Sort by confidence descending for greedy NMS
        val sorted = candidates.sortedByDescending { it.confidence }

        // Apply Non-Maximum Suppression (NMS)
        val kept = mutableListOf<RawDetection>()
        val suppressed = BooleanArray(sorted.size)

        for (i in sorted.indices) {
            if (suppressed[i]) continue
            val a = sorted[i]
            kept.add(a)

            for (j in i + 1 until sorted.size) {
                if (suppressed[j]) continue
                if (computeIoU(a, sorted[j]) > iouThreshold) {
                    suppressed[j] = true
                }
            }
        }

        // Convert to Flutter-compatible output format
        return kept.map { det ->
            mapOf<String, Any>(
                "x" to det.x.toDouble(),
                "y" to det.y.toDouble(),
                "width" to det.width.toDouble(),
                "height" to det.height.toDouble(),
                "confidence" to det.confidence.toDouble()
            )
        }
    }

    /**
     * Computes Intersection over Union (IoU) between two detections
     * using center-format coordinates (cx, cy, w, h), all normalized 0..1.
     */
    private fun computeIoU(a: RawDetection, b: RawDetection): Float {
        // Convert center format to corner format
        val aLeft   = a.x - a.width / 2f
        val aTop    = a.y - a.height / 2f
        val aRight  = a.x + a.width / 2f
        val aBottom = a.y + a.height / 2f

        val bLeft   = b.x - b.width / 2f
        val bTop    = b.y - b.height / 2f
        val bRight  = b.x + b.width / 2f
        val bBottom = b.y + b.height / 2f

        // Intersection rectangle
        val interLeft   = max(aLeft, bLeft)
        val interTop    = max(aTop, bTop)
        val interRight  = min(aRight, bRight)
        val interBottom = min(aBottom, bBottom)

        val interWidth  = max(0f, interRight - interLeft)
        val interHeight = max(0f, interBottom - interTop)
        val interArea   = interWidth * interHeight

        val aArea = a.width * a.height
        val bArea = b.width * b.height
        val unionArea = aArea + bArea - interArea

        return if (unionArea > 0f) interArea / unionArea else 0f
    }
}
