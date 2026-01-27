import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbell Path Tracker',
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
      appBar: AppBar(title: const Text('바벨 패스 트래커')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrackingPage()),
            );
          },
          child: const Text('트래킹 시작'),
        ),
      ),
    );
  }
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final List<Offset> _path = [];
  static const double _maxJumpDistance = 0.15;  // 최대 이동 거리 (화면 비율)

  bool _isTracking = false;
  bool _showBox = true;  // 바운딩 박스 표시 여부
  double _confidence = 0;
  Rect? _boundingBox;
  Offset? _lastValidPosition;  // 마지막 유효 위치
  int _lostFrames = 0;  // 감지 못한 프레임 수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // YOLO 카메라
          Positioned.fill(
            child: YOLOView(
              modelPath: 'barbell_detector',
              task: YOLOTask.detect,
              onResult: _onResult,
            ),
          ),

          // 바운딩 박스 표시 (토글 가능)
          if (_boundingBox != null && _showBox)
            Positioned.fill(
              child: CustomPaint(
                painter: _BoxPainter(_boundingBox!),
              ),
            ),

          // 패스 그리기
          if (_path.length > 1)
            Positioned.fill(
              child: CustomPaint(
                painter: _PathPainter(_path),
              ),
            ),

          // 뒤로가기
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 상태 표시
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                '신뢰도: ${(_confidence * 100).toInt()}%\n포인트: ${_path.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // 컨트롤 버튼
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 시작/정지
                GestureDetector(
                  onTap: () => setState(() {
                    _isTracking = !_isTracking;
                    if (_isTracking) {
                      _path.clear();
                      _lastValidPosition = null;
                    }
                  }),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTracking ? Colors.red : Colors.green,
                    ),
                    child: Icon(
                      _isTracking ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                // 초기화
                GestureDetector(
                  onTap: () => setState(() => _path.clear()),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[700],
                    ),
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 30),
                // 박스 표시 토글
                GestureDetector(
                  onTap: () => setState(() => _showBox = !_showBox),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _showBox ? Colors.blue : Colors.grey[700],
                    ),
                    child: const Icon(Icons.crop_square, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onResult(List<YOLOResult> results) {
    if (results.isEmpty) {
      setState(() {
        _lostFrames++;
        // 10프레임 이상 감지 못하면 박스 숨김
        if (_lostFrames > 10) {
          _boundingBox = null;
          _confidence = 0;
        }
      });
      return;
    }

    // 가장 높은 신뢰도 결과
    final best = results.reduce((a, b) => a.confidence > b.confidence ? a : b);
    final box = best.normalizedBox;
    final center = Offset((box.left + box.right) / 2, (box.top + box.bottom) / 2);

    // 위치 검증: 이전 위치에서 너무 멀면 무시
    if (_lastValidPosition != null) {
      final distance = (center - _lastValidPosition!).distance;
      if (distance > _maxJumpDistance && best.confidence < 0.8) {
        // 신뢰도 높으면 점프 허용, 아니면 무시
        return;
      }
    }

    _lostFrames = 0;

    setState(() {
      _confidence = best.confidence;
      _boundingBox = box;

      if (_isTracking && best.confidence > 0.5) {
        _lastValidPosition = center;

        // 감지된 위치만 기록 (중복 방지)
        if (_path.isEmpty || (_path.last - center).distance > 0.005) {
          _path.add(center);
          if (_path.length > 500) _path.removeAt(0);
        }
      }
    });
  }
}

class _BoxPainter extends CustomPainter {
  final Rect box;
  _BoxPainter(this.box);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      box.left * size.width,
      box.top * size.height,
      box.right * size.width,
      box.bottom * size.height,
    );
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, paint);

    // 중심점
    final center = rect.center;
    canvas.drawCircle(center, 8, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant _BoxPainter old) => box != old.box;
}

class _PathPainter extends CustomPainter {
  final List<Offset> path;
  _PathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    // 스크린 좌표로 변환
    final screenPath = path.map((p) =>
      Offset(p.dx * size.width, p.dy * size.height)
    ).toList();

    // 선 그리기 (점과 점 직선 연결)
    if (screenPath.length >= 2) {
      final linePaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 1; i < screenPath.length; i++) {
        canvas.drawLine(screenPath[i - 1], screenPath[i], linePaint);
      }
    }

    // 각 감지 지점에 점 찍기
    final dotPaint = Paint()..color = Colors.cyan;
    for (final point in screenPath) {
      canvas.drawCircle(point, 4, dotPaint);
    }

    // 현재 위치 (마지막 점) 강조
    final lastPoint = screenPath.last;
    canvas.drawCircle(
      lastPoint,
      8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      lastPoint,
      5,
      Paint()..color = Colors.cyan,
    );
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => path.length != old.path.length;
}
