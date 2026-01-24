import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'dart:ui' as ui;

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
      title: 'Barbell Tracking Demo',
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
              'Barbell Path Tracking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'YOLOv8 기반 실시간 바벨 감지',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _startTracking(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Tracking'),
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

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final List<Offset> _pathHistory = [];
  static const int _maxPathPoints = 500;
  int _frameCount = 0;
  Offset? _currentPosition;
  double _currentConfidence = 0;
  String _detectedLabel = '';
  bool _isTracking = false;

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
              onResult: (results) {
                if (!_isTracking) return;

                _frameCount++;

                if (results.isNotEmpty) {
                  // barbell 클래스 필터링
                  final barbellResults = results.where((r) =>
                    r.className.toLowerCase().contains('barbell') &&
                    r.confidence >= 0.5
                  ).toList();

                  dynamic best;
                  if (barbellResults.isNotEmpty) {
                    best = barbellResults.reduce((a, b) =>
                      a.confidence > b.confidence ? a : b
                    );
                  } else if (results.first.confidence >= 0.5) {
                    best = results.first;
                  }

                  if (best != null) {
                    final centerX = (best.boundingBox.left + best.boundingBox.right) / 2;
                    final centerY = (best.boundingBox.top + best.boundingBox.bottom) / 2;

                    setState(() {
                      _currentPosition = Offset(centerX, centerY);
                      _currentConfidence = best.confidence;
                      _detectedLabel = best.className;

                      // 정규화된 좌표로 패스 히스토리 추가
                      _pathHistory.add(Offset(centerX, centerY));
                      if (_pathHistory.length > _maxPathPoints) {
                        _pathHistory.removeAt(0);
                      }
                    });
                  }
                }
              },
            ),
          ),

          // Path Trail Overlay
          if (_pathHistory.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: PathTrailPainter(
                  pathPoints: List.from(_pathHistory),
                ),
              ),
            ),

          // Current Position Indicator
          if (_currentPosition != null)
            Positioned.fill(
              child: CustomPaint(
                painter: CurrentPositionPainter(
                  position: _currentPosition!,
                ),
              ),
            ),

          // Top Bar
          Positioned(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                        _isTracking ? '트래킹 중...' : '준비',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOLO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Metrics Panel
          Positioned(
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
                    '패스 포인트: ${_pathHistory.length}',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_detectedLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '클래스: $_detectedLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (_currentConfidence > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '신뢰도: ${(_currentConfidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  Text(
                    '프레임: $_frameCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
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
                      _pathHistory.clear();
                      _frameCount = 0;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('시작'),
                  ),
                if (_isTracking) ...[
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isTracking = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('정지'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _pathHistory.clear()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('초기화'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 패스 궤적 Painter
class PathTrailPainter extends CustomPainter {
  final List<Offset> pathPoints;

  PathTrailPainter({required this.pathPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (pathPoints.length < 2) return;

    for (int i = 1; i < pathPoints.length; i++) {
      final startPoint = Offset(
        pathPoints[i - 1].dx * size.width,
        pathPoints[i - 1].dy * size.height,
      );
      final endPoint = Offset(
        pathPoints[i].dx * size.width,
        pathPoints[i].dy * size.height,
      );

      final opacity = (i / pathPoints.length).clamp(0.1, 1.0);
      final strokeWidth = 2.0 + (i / pathPoints.length) * 4.0;

      final paint = Paint()
        ..color = Colors.cyan.withValues(alpha: opacity)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PathTrailPainter oldDelegate) {
    return pathPoints.length != oldDelegate.pathPoints.length;
  }
}

/// 현재 위치 표시 Painter
class CurrentPositionPainter extends CustomPainter {
  final Offset position;

  CurrentPositionPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final point = Offset(
      position.dx * size.width,
      position.dy * size.height,
    );

    // 글로우 효과
    final glowPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 25, glowPaint);

    // 메인 포인트
    final centerPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 12, centerPaint);

    // 내부 흰색 점
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CurrentPositionPainter oldDelegate) {
    return position != oldDelegate.position;
  }
}
