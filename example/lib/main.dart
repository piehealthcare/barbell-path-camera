import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

late List<dynamic> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbell Path Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbell Path Camera'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              '바벨 패스 트래킹',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'YOLOv8 기반 실시간 바벨 끝단 감지',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _startTracking(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('트래킹 시작'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTracking(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 권한이 필요합니다')),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TrackingPage(),
        ),
      );
    }
  }
}

/// 바벨 끝단 위치 정보
class BarbellEndpoint {
  final Offset position;
  final double confidence;
  final Rect boundingBox;
  final DateTime timestamp;

  BarbellEndpoint({
    required this.position,
    required this.confidence,
    required this.boundingBox,
    required this.timestamp,
  });
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  // 바벨 끝단 패스 히스토리 (최대 2개 끝단 트래킹)
  final List<BarbellEndpoint> _leftPathHistory = [];
  final List<BarbellEndpoint> _rightPathHistory = [];
  static const int _maxPathPoints = 300;

  int _frameCount = 0;
  int _detectionCount = 0;
  bool _isTracking = false;
  bool _showBoundingBox = true;

  // 현재 감지된 바벨 끝단들
  List<Rect> _currentBoundingBoxes = [];
  List<Offset> _currentEndpoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // YOLOView로 실시간 감지
          Positioned.fill(
            child: YOLOView(
              modelPath: 'barbell_detector',
              task: YOLOTask.detect,
              onResult: _handleDetectionResult,
            ),
          ),

          // Bounding Box Overlay (디버깅용)
          if (_showBoundingBox && _currentBoundingBoxes.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: BoundingBoxPainter(
                  boxes: _currentBoundingBoxes,
                  endpoints: _currentEndpoints,
                ),
              ),
            ),

          // 바벨 패스 Overlay
          if (_isTracking)
            Positioned.fill(
              child: CustomPaint(
                painter: BarbellPathPainter(
                  leftPath: List.from(_leftPathHistory),
                  rightPath: List.from(_rightPathHistory),
                ),
              ),
            ),

          // Top Bar
          _buildTopBar(),

          // Info Panel
          _buildInfoPanel(),

          // Bottom Controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  void _handleDetectionResult(List<dynamic> results) {
    _frameCount++;

    if (results.isEmpty) {
      if (_frameCount % 60 == 0) {
        debugPrint('프레임 $_frameCount: 감지 없음');
      }
      setState(() {
        _currentBoundingBoxes = [];
        _currentEndpoints = [];
      });
      return;
    }

    _detectionCount++;

    // 바벨 플레이트 끝단 감지 결과 처리
    final detectedBoxes = <Rect>[];
    final detectedEndpoints = <Offset>[];

    for (final result in results) {
      // barbell_plate_side 클래스만 필터링
      final className = result.className.toString().toLowerCase();
      if (!className.contains('barbell') && !className.contains('plate')) {
        continue;
      }

      final box = result.boundingBox;
      final rect = Rect.fromLTRB(
        box.left.toDouble(),
        box.top.toDouble(),
        box.right.toDouble(),
        box.bottom.toDouble(),
      );

      // 바운딩 박스의 중심점 = 바벨 끝단 위치
      final centerX = (box.left + box.right) / 2;
      final centerY = (box.top + box.bottom) / 2;

      detectedBoxes.add(rect);
      detectedEndpoints.add(Offset(centerX, centerY));

      if (_frameCount % 30 == 0) {
        debugPrint('바벨 끝단 감지: ($centerX, $centerY), 신뢰도: ${(result.confidence * 100).toStringAsFixed(1)}%');
      }
    }

    setState(() {
      _currentBoundingBoxes = detectedBoxes;
      _currentEndpoints = detectedEndpoints;
    });

    // 트래킹 중일 때만 패스 기록
    if (_isTracking && detectedEndpoints.isNotEmpty) {
      _recordPath(detectedEndpoints);
    }
  }

  void _recordPath(List<Offset> endpoints) {
    final now = DateTime.now();

    // X 좌표 기준으로 왼쪽/오른쪽 끝단 분류
    endpoints.sort((a, b) => a.dx.compareTo(b.dx));

    if (endpoints.isNotEmpty) {
      // 가장 왼쪽 끝단
      final leftEndpoint = BarbellEndpoint(
        position: endpoints.first,
        confidence: 1.0,
        boundingBox: _currentBoundingBoxes.isNotEmpty
            ? _currentBoundingBoxes.first
            : Rect.zero,
        timestamp: now,
      );
      _leftPathHistory.add(leftEndpoint);
      if (_leftPathHistory.length > _maxPathPoints) {
        _leftPathHistory.removeAt(0);
      }
    }

    if (endpoints.length >= 2) {
      // 가장 오른쪽 끝단
      final rightEndpoint = BarbellEndpoint(
        position: endpoints.last,
        confidence: 1.0,
        boundingBox: _currentBoundingBoxes.isNotEmpty
            ? _currentBoundingBoxes.last
            : Rect.zero,
        timestamp: now,
      );
      _rightPathHistory.add(rightEndpoint);
      if (_rightPathHistory.length > _maxPathPoints) {
        _rightPathHistory.removeAt(0);
      }
    }
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _isTracking ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isTracking ? '바패스 트래킹 중' : '대기',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showBoundingBox = !_showBoundingBox),
            icon: Icon(
              _showBoundingBox ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 60,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프레임: $_frameCount',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              '감지: $_detectionCount',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Divider(color: Colors.white24, height: 16),
            Text(
              '왼쪽 패스: ${_leftPathHistory.length}',
              style: const TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              '오른쪽 패스: ${_rightPathHistory.length}',
              style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (_currentEndpoints.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '현재 끝단: ${_currentEndpoints.length}개',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isTracking)
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _isTracking = true;
                _leftPathHistory.clear();
                _rightPathHistory.clear();
                _frameCount = 0;
                _detectionCount = 0;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('트래킹 시작'),
            ),
          if (_isTracking) ...[
            ElevatedButton.icon(
              onPressed: () => setState(() => _isTracking = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.stop),
              label: const Text('정지'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _leftPathHistory.clear();
                _rightPathHistory.clear();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('초기화'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 바운딩 박스 Painter (디버깅용)
class BoundingBoxPainter extends CustomPainter {
  final List<Rect> boxes;
  final List<Offset> endpoints;

  BoundingBoxPainter({required this.boxes, required this.endpoints});

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final endpointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final box in boxes) {
      // 정규화된 좌표를 실제 화면 좌표로 변환
      final rect = Rect.fromLTRB(
        box.left * size.width,
        box.top * size.height,
        box.right * size.width,
        box.bottom * size.height,
      );
      canvas.drawRect(rect, boxPaint);
    }

    for (final point in endpoints) {
      final screenPoint = Offset(
        point.dx * size.width,
        point.dy * size.height,
      );
      canvas.drawCircle(screenPoint, 8, endpointPaint);

      // 십자선
      final crossPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(screenPoint.dx - 12, screenPoint.dy),
        Offset(screenPoint.dx + 12, screenPoint.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(screenPoint.dx, screenPoint.dy - 12),
        Offset(screenPoint.dx, screenPoint.dy + 12),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) => true;
}

/// 바벨 패스 Painter
class BarbellPathPainter extends CustomPainter {
  final List<BarbellEndpoint> leftPath;
  final List<BarbellEndpoint> rightPath;

  BarbellPathPainter({required this.leftPath, required this.rightPath});

  @override
  void paint(Canvas canvas, Size size) {
    // 왼쪽 끝단 패스 (cyan)
    _drawPath(canvas, size, leftPath, Colors.cyan);

    // 오른쪽 끝단 패스 (orange)
    _drawPath(canvas, size, rightPath, Colors.orange);
  }

  void _drawPath(Canvas canvas, Size size, List<BarbellEndpoint> path, Color color) {
    if (path.length < 2) return;

    final pathPaint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < path.length; i++) {
      final startPoint = Offset(
        path[i - 1].position.dx * size.width,
        path[i - 1].position.dy * size.height,
      );
      final endPoint = Offset(
        path[i].position.dx * size.width,
        path[i].position.dy * size.height,
      );

      // 그라데이션 효과: 최근 포인트일수록 밝게
      final opacity = (i / path.length).clamp(0.2, 1.0);
      pathPaint.color = color.withValues(alpha: opacity);

      canvas.drawLine(startPoint, endPoint, pathPaint);
    }

    // 현재 위치에 포인트 표시
    if (path.isNotEmpty) {
      final lastPoint = Offset(
        path.last.position.dx * size.width,
        path.last.position.dy * size.height,
      );

      // 글로우 효과
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 20, glowPaint);

      // 메인 포인트
      final centerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 10, centerPaint);

      // 흰색 내부
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 4, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BarbellPathPainter oldDelegate) {
    return leftPath.length != oldDelegate.leftPath.length ||
           rightPath.length != oldDelegate.rightPath.length;
  }
}
