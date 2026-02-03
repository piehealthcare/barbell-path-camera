package com.point.point_barbell_path

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.os.Environment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer

class VideoCompositorPlugin : MethodChannel.MethodCallHandler {
    private var mediaCodec: MediaCodec? = null
    private var mediaMuxer: MediaMuxer? = null
    private var trackIndex = -1
    private var isRecording = false
    private var frameCount = 0L
    private var fps = 30
    private var outputPath: String? = null
    private var muxerStarted = false

    companion object {
        fun registerWith(flutterEngine: FlutterEngine) {
            val channel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "video_compositor"
            )
            channel.setMethodCallHandler(VideoCompositorPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startRecording" -> {
                val width = call.argument<Int>("width") ?: 720
                val height = call.argument<Int>("height") ?: 1280
                val fps = call.argument<Int>("fps") ?: 30
                val bitrate = call.argument<Int>("bitrate") ?: 8000000
                startRecording(width, height, fps, bitrate, result)
            }
            "addFrame" -> {
                val cameraFrame = call.argument<ByteArray>("cameraFrame")
                val width = call.argument<Int>("width") ?: 0
                val height = call.argument<Int>("height") ?: 0
                val overlayPng = call.argument<ByteArray>("overlayPng")
                addFrame(cameraFrame, overlayPng, width, height, result)
            }
            "stopRecording" -> {
                stopRecording(result)
            }
            else -> result.notImplemented()
        }
    }

    private fun startRecording(width: Int, height: Int, fps: Int, bitrate: Int, result: MethodChannel.Result) {
        try {
            this.fps = fps
            frameCount = 0

            val timestamp = System.currentTimeMillis()
            val cacheDir = File(System.getProperty("java.io.tmpdir") ?: "/tmp")
            outputPath = File(cacheDir, "point_barbell_$timestamp.mp4").absolutePath

            val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height)
            format.setInteger(MediaFormat.KEY_BIT_RATE, bitrate)
            format.setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
            format.setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface
            )

            mediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
            mediaCodec?.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            mediaCodec?.start()

            mediaMuxer = MediaMuxer(outputPath!!, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)

            isRecording = true
            muxerStarted = false
            result.success(true)
        } catch (e: Exception) {
            isRecording = false
            result.success(false)
        }
    }

    private fun addFrame(
        cameraFrame: ByteArray?,
        overlayPng: ByteArray?,
        width: Int,
        height: Int,
        result: MethodChannel.Result
    ) {
        if (!isRecording || cameraFrame == null || mediaCodec == null) {
            result.success(null)
            return
        }

        try {
            val inputBufferIndex = mediaCodec!!.dequeueInputBuffer(10000)
            if (inputBufferIndex >= 0) {
                val inputBuffer = mediaCodec!!.getInputBuffer(inputBufferIndex)
                inputBuffer?.clear()
                inputBuffer?.put(cameraFrame)

                val presentationTimeUs = frameCount * 1_000_000L / fps
                mediaCodec!!.queueInputBuffer(
                    inputBufferIndex, 0, cameraFrame.size,
                    presentationTimeUs, 0
                )
                frameCount++
            }

            drainEncoder(false)
            result.success(null)
        } catch (e: Exception) {
            result.success(null)
        }
    }

    private fun drainEncoder(endOfStream: Boolean) {
        if (endOfStream) {
            mediaCodec?.signalEndOfInputStream()
        }

        val bufferInfo = MediaCodec.BufferInfo()
        while (true) {
            val outputBufferIndex = mediaCodec?.dequeueOutputBuffer(bufferInfo, 10000) ?: break

            if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                val newFormat = mediaCodec!!.outputFormat
                trackIndex = mediaMuxer!!.addTrack(newFormat)
                mediaMuxer!!.start()
                muxerStarted = true
            } else if (outputBufferIndex >= 0) {
                val outputBuffer = mediaCodec!!.getOutputBuffer(outputBufferIndex) ?: continue

                if (muxerStarted && bufferInfo.size > 0) {
                    outputBuffer.position(bufferInfo.offset)
                    outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                    mediaMuxer?.writeSampleData(trackIndex, outputBuffer, bufferInfo)
                }

                mediaCodec!!.releaseOutputBuffer(outputBufferIndex, false)

                if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                    break
                }
            } else {
                break
            }
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        if (!isRecording) {
            result.success(null)
            return
        }

        try {
            isRecording = false
            drainEncoder(true)

            mediaCodec?.stop()
            mediaCodec?.release()
            mediaCodec = null

            mediaMuxer?.stop()
            mediaMuxer?.release()
            mediaMuxer = null

            result.success(outputPath)
        } catch (e: Exception) {
            result.success(null)
        }
    }
}
