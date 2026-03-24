import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

const double kaabaLat = 21.422510;
const double kaabaLng = 39.826168;

double calculateQibla(double userLat, double userLng) {
  final lat1 = userLat * pi / 180;
  final lat2 = kaabaLat * pi / 180;
  final dLon = (kaabaLng - userLng) * pi / 180;

  final y = sin(dLon);
  final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

  final bearing = atan2(y, x);
  return (bearing * 180 / pi + 360) % 360;
}

double calculateDistance(double userLat, double userLng) {
  const earthRadius = 6371.0; // km
  final dLat = (kaabaLat - userLat) * pi / 180;
  final dLon = (kaabaLng - userLng) * pi / 180;

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(userLat * pi / 180) *
          cos(kaabaLat * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  Position? _position;
  double? _qiblaDirection;
  double? _distance;
  String? _errorMessage;
  bool _isCalibrating = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      // Check GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'الرجاء تفعيل خدمة الموقع\nPlease enable location services';
        });
        return;
      }

      // Check Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'يجب السماح بالوصول للموقع\nLocation permission required';
        });
        return;
      }

      // Get Location with timeout
      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('فشل في الحصول على الموقع\nLocation timeout');
        },
      );

      // Calculate Qibla & Distance
      _qiblaDirection = calculateQibla(
        _position!.latitude,
        _position!.longitude,
      );

      _distance = calculateDistance(
        _position!.latitude,
        _position!.longitude,
      );

      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'اتجاه القبلة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Qibla Direction',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildError();
    }

    if (_position == null || _qiblaDirection == null) {
      return _buildLoading();
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoading();
        }

        double? deviceHeading = snapshot.data!.heading;

        if (deviceHeading == null) {
          return _buildError(
            message: 'البوصلة غير متوفرة\nCompass not available',
          );
        }

        double rotation = (_qiblaDirection! - deviceHeading) * pi / 180;
        double angleDifference =
            ((_qiblaDirection! - deviceHeading).abs()) % 360;
        if (angleDifference > 180) angleDifference = 360 - angleDifference;

        bool isAligned = angleDifference < 5;

        return _buildCompass(rotation, deviceHeading, isAligned);
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'جاري تحديد الموقع...\nDetecting location...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              message ?? _errorMessage ?? 'حدث خطأ\nAn error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
           const  SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _position = null;
                  _qiblaDirection = null;
                });
                _init();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة / Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: const Color(0xFF0A1128),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(double rotation, double heading, bool isAligned) {
    return Stack(
      children: [
        // Background circles
        Positioned.fill(
          child: CustomPaint(
            painter: CompassBackgroundPainter(),
          ),
        ),

        // Main content
        Column(
          children: [
            const SizedBox(height: 20),

            // Location info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'المسافة\nDistance',
                        '${_distance!.toStringAsFixed(0)} km',
                        Icons.map,
                      ),
                      _buildInfoItem(
                        'خط العرض\nLatitude',
                        '${_position!.latitude.toStringAsFixed(4)}°',
                        Icons.public,
                      ),
                      _buildInfoItem(
                        'خط الطول\nLongitude',
                        '${_position!.longitude.toStringAsFixed(4)}°',
                        Icons.explore,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Compass container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse effect when aligned
                        if (isAligned)
                          FadeTransition(
                            opacity: _pulseController,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF00FF88),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                        // Main compass circle
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF1A2744),
                                Color(0xFF0A1128),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:const  Color(0xFF00D9FF).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),

                        // Compass directions
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: CompassDirectionsPainter(heading),
                          ),
                        ),

                        // Kaaba icon and arrow
                        Transform.rotate(
                          angle: rotation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 40,
                                color: isAligned
                                    ?const  Color(0xFF00FF88)
                                    :const  Color(0xFF00D9FF),
                              ),
                             const  SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'الكعبة\nKaaba',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 60,
                                color: isAligned
                                    ? Color(0xFF00FF88)
                                    : Color(0xFF00D9FF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // Status indicator
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? Color(0xFF00FF88).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isAligned ? Color(0xFF00FF88) : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAligned ? Icons.check_circle : Icons.navigation,
                            color: isAligned
                                ? Color(0xFF00FF88)
                                : Color(0xFF00D9FF),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            isAligned
                                ? 'الاتجاه صحيح ✓\nCorrectly Aligned'
                                : 'استمر بالتدوير\nKeep Rotating',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Qibla angle
                    Text(
                      '${_qiblaDirection!.toStringAsFixed(1)}°',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calibration hint
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'للدقة: حرك الهاتف على شكل رقم 8\nFor accuracy: Move phone in figure-8 pattern',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF00D9FF), size: 20),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class CompassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 1; i <= 3; i++) {
      paint.color = Colors.white.withOpacity(0.05);
      canvas.drawCircle(center, 100.0 * i, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompassDirectionsPainter extends CustomPainter {
  final double heading;

  CompassDirectionsPainter(this.heading);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final angle = (angles[i] - heading) * pi / 180;
      final x = center.dx + radius * sin(angle);
      final y = center.dy - radius * cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? const Color(0xFFFF4757) : Colors.white70,
          fontSize: i == 0 ? 20 : 16,
          fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CompassDirectionsPainter oldDelegate) =>
      heading != oldDelegate.heading;
}
