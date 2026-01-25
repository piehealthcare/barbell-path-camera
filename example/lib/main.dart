import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

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
        title: const Text('바벨 패스 트래커'),
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
              '바벨 끝단의 이동 경로를 추적합니다',
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
        MaterialPageRoute(builder: (context) => const TrackingPage()),
      );
    }
  }
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  // 바벨 끝단 패스 히스토리
  final List<Offset> _pathHistory = [];
  static const int _maxPathPoints = 500;

  int _detectionCount = 0;
  bool _isTracking = false;
  bool _showBoundingBox = true;

  // 현재 감지된 바벨 끝단
  Rect? _currentBox;
  Offset? _currentEndpoint;
  double _currentConfidence = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // YOLO 카메라 프리뷰
          Positioned.fill(
            child: YOLOView(
              modelPath: 'barbell_endpoint.mlpackage',
              task: YOLOTask.detect,
              showNativeUI: false,
              showOverlays: _showBoundingBox,
              confidenceThreshold: 0.3,
              onResult: _handleDetectionResult,
            ),
          ),

          // 바벨 패스 오버레이
          if (_pathHistory.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: PathPainter(path: List.from(_pathHistory)),
              ),
            ),

          // 현재 위치 마커
          if (_currentEndpoint != null)
            Positioned.fill(
              child: CustomPaint(
                painter: EndpointPainter(endpoint: _currentEndpoint!),
              ),
            ),

          // 상단 바
          _buildTopBar(),

          // 정보 패널
          _buildInfoPanel(),

          // 하단 컨트롤
          _buildBottomControls(),
        ],
      ),
    );
  }

  void _handleDetectionResult(List<YOLOResult> results) {
    if (results.isEmpty) {
      setState(() {
        _currentBox = null;
        _currentEndpoint = null;
      });
      return;
    }

    // 가장 신뢰도 높은 결과 선택
    YOLOResult? best;
    double bestConf = 0;

    for (final result in results) {
      if (result.confidence > bestConf) {
        bestConf = result.confidence;
        best = result;
      }
    }

    if (best != null) {
      final box = best.normalizedBox;

      final centerX = (box.left + box.right) / 2;
      final centerY = (box.top + box.bottom) / 2;
      final endpoint = Offset(centerX, centerY);

      _detectionCount++;

      setState(() {
        _currentBox = box;
        _currentEndpoint = endpoint;
        _currentConfidence = bestConf;
      });

      // 트래킹 중일 때만 패스 기록
      if (_isTracking) {
        _pathHistory.add(endpoint);
        if (_pathHistory.length > _maxPathPoints) {
          _pathHistory.removeAt(0);
        }
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isTracking ? Colors.green.withOpacity(0.8) : Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _isTracking ? Icons.fiber_manual_record : Icons.pause,
                  color: _isTracking ? Colors.white : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isTracking ? 'REC' : '대기',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
      top: MediaQuery.of(context).padding.top + 70,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '패스: ${_pathHistory.length}',
              style: const TextStyle(
                color: Colors.cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '신뢰도: ${(_currentConfidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: _currentConfidence > 0.7 ? Colors.green : Colors.orange,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40 + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 트래킹 시작/정지 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                if (_isTracking) {
                  _isTracking = false;
                } else {
                  _isTracking = true;
                  _pathHistory.clear();
                }
              });
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTracking ? Colors.red : Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: (_isTracking ? Colors.red : Colors.green).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isTracking ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 32),
          // 초기화 버튼
          GestureDetector(
            onTap: () => setState(() => _pathHistory.clear()),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[800],
              ),
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 현재 위치 마커 Painter
class EndpointPainter extends CustomPainter {
  final Offset endpoint;

  EndpointPainter({required this.endpoint});

  @override
  void paint(Canvas canvas, Size size) {
    final point = Offset(
      endpoint.dx * size.width,
      endpoint.dy * size.height,
    );

    // 십자선
    final markerPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(point.dx - 20, point.dy),
      Offset(point.dx + 20, point.dy),
      markerPaint,
    );
    canvas.drawLine(
      Offset(point.dx, point.dy - 20),
      Offset(point.dx, point.dy + 20),
      markerPaint,
    );

    // 중심점
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 8, centerPaint);
  }

  @override
  bool shouldRepaint(covariant EndpointPainter oldDelegate) => true;
}

/// 패스 Painter
class PathPainter extends CustomPainter {
  final List<Offset> path;

  PathPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    // 패스 라인
    for (int i = 1; i < path.length; i++) {
      final start = Offset(
        path[i - 1].dx * size.width,
        path[i - 1].dy * size.height,
      );
      final end = Offset(
        path[i].dx * size.width,
        path[i].dy * size.height,
      );

      // 그라데이션 효과
      final progress = i / path.length;
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(0.3 + progress * 0.7)
        ..strokeWidth = 2 + progress * 4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start, end, paint);
    }

    // 현재 위치 표시
    if (path.isNotEmpty) {
      final current = Offset(
        path.last.dx * size.width,
        path.last.dy * size.height,
      );

      // 글로우
      final glowPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(current, 25, glowPaint);

      // 메인 원
      final mainPaint = Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.fill;
      canvas.drawCircle(current, 12, mainPaint);

      // 내부 흰색
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(current, 5, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return path.length != oldDelegate.path.length;
  }
}
