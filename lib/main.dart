// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:logger/logger.dart';

// AI Client
class AIClient {
  static const String apiKey =
      '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';
  static const String apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  final Logger logger = Logger();

  Future<String> processInput(String input, String language) async {
    try {
      logger.i(
        'Preparing Groq API request for input: $input, language: $language',
      );
      final body = jsonEncode({
        'model': 'gemma2-9b-it',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a coding assistant for beginners. Provide simple, beginner-friendly explanations and accurate $language code examples.',
          },
          {'role': 'user', 'content': input},
        ],
        'max_tokens': 2048,
        'temperature': 0.10,
      });

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final output = data['choices'][0]['message']['content'].trim();
        return output.isNotEmpty ? output : '// No response from AI.';
      } else {
        final errorMessage =
            jsonDecode(response.body)['error']?['message'] ?? response.body;
        return '// Error: Failed to fetch response (Status: ${response.statusCode}, Message: $errorMessage)';
      }
    } catch (e) {
      logger.e('API error: $e');
      return '// Error: Unable to connect to Groq API ($e)';
    }
  }
}

// BLoC
abstract class CodeEvent {}

class ProcessCodeEvent extends CodeEvent {
  final String input;
  final String language;
  ProcessCodeEvent(this.input, this.language);
}

class CodeState {
  final String? output;
  final bool isLoading;
  final String? error;

  CodeState({this.output, this.isLoading = false, this.error});

  CodeState copyWith({String? output, bool? isLoading, String? error}) {
    return CodeState(
      output: output ?? this.output,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CodeBloc extends Bloc<CodeEvent, CodeState> {
  final AIClient aiClient = AIClient();

  CodeBloc() : super(CodeState()) {
    on<ProcessCodeEvent>(_onProcessCode);
  }

  Future<void> _onProcessCode(
    ProcessCodeEvent event,
    Emitter<CodeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final output = await aiClient.processInput(event.input, event.language);
      emit(state.copyWith(output: output, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

void main() {
  runApp(const FlightWeatherApp());
}

class FlightWeatherApp extends StatelessWidget {
  const FlightWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeCraft AI',
      theme: ThemeData(
        primaryColor: Colors.purple[800],
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.light(
          primary: Colors.purple[800]!,
          secondary: Colors.cyan[300]!,
          // ignore: deprecated_member_use
          surface: Colors.blue[50]!.withOpacity(0.9),
        ),
        textTheme: GoogleFonts.orbitronTextTheme(
          TextTheme(
            bodyMedium: TextStyle(color: Colors.purple[800], fontSize: 16),
            titleLarge: TextStyle(
              color: Colors.purple[800],
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
            titleMedium: TextStyle(
              color: Colors.purple[800],
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            labelLarge: TextStyle(
              color: Colors.purple[800],
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[300],
            foregroundColor: Colors.purple[800],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            // ignore: deprecated_member_use
            shadowColor: Colors.cyan[200]!.withOpacity(0.4),
          ),
        ),
        cardTheme: CardTheme(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          // ignore: deprecated_member_use
          fillColor: Colors.white.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: GoogleFonts.orbitron(color: Colors.purple[800]),
          hintStyle: GoogleFonts.orbitron(color: Colors.purple[600]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIconColor: Colors.purple[600],
        ),
      ),
      home: BlocProvider(
        create: (context) => CodeBloc(),
        child: const CodeHelperScreen(),
      ),
    );
  }
}

class CodeHelperScreen extends StatelessWidget {
  const CodeHelperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple[700]!,
                  Colors.blue[300]!,
                  Colors.cyan[100]!,
                ],
              ),
            ),
          ),
          const ParticleBackground(),
          const InputTab(),
        ],
      ),
    );
  }
}

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  ParticleBackgroundState createState() => ParticleBackgroundState();
}

class ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset? _touchPoint;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeParticles();
    });
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;
    _particles = List.generate(50, (index) {
      return Particle(
        position: Offset(
          Random().nextDouble() * size.width,
          Random().nextDouble() * size.height,
        ),
      );
    });
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateTouchPoint(Offset? newPoint) {
    setState(() {
      _touchPoint = newPoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => _updateTouchPoint(details.localPosition),
      onPanEnd: (details) => _updateTouchPoint(null),
      onTapDown: (details) => _updateTouchPoint(details.localPosition),
      onTapUp: (details) => _updateTouchPoint(null),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              _particles,
              _touchPoint,
              _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  double baseOpacity;
  double targetScale;

  Particle({required this.position})
    : velocity = Offset(
        (Random().nextDouble() - 0.5) * 3,
        (Random().nextDouble() - 0.5) * 3,
      ),
      radius = Random().nextDouble() * 2 + 1.5,
      baseOpacity = Random().nextDouble() * 0.5 + 0.5,
      targetScale = 1.0;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset? touchPoint;
  final double animationValue;
  final Random _random = Random();

  ParticlePainter(this.particles, this.touchPoint, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.srcOver;

    final linePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          // ignore: deprecated_member_use
          ..color = Colors.cyan[400]!.withOpacity(0.3);

    for (var particle in particles) {
      if (touchPoint != null) {
        final direction = touchPoint! - particle.position;
        final distance = direction.distance;
        if (distance < 150) {
          final attraction = direction / distance * 1.5;
          particle.velocity += attraction;
          particle.velocity *= 0.9;
          particle.targetScale = 1.5;
          particle.velocity += Offset(
            -direction.dy / distance * 0.8,
            direction.dx / distance * 0.8,
          );
        } else {
          particle.velocity *= 0.95;
          particle.targetScale = 1.0;
        }
      } else {
        particle.velocity = Offset(
          particle.velocity.dx * 0.98 + (_random.nextDouble() - 0.5) * 0.3,
          particle.velocity.dy * 0.98 + (_random.nextDouble() - 0.5) * 0.3,
        );
        particle.targetScale = 1.0;
      }

      particle.position += particle.velocity;
      particle.position = Offset(
        (particle.position.dx + size.width) % size.width,
        (particle.position.dy + size.height) % size.height,
      );

      particle.radius +=
          (particle.targetScale * (Random().nextDouble() * 2 + 1.5) -
              particle.radius) *
          0.1;

      final pulse = 0.3 * sin(animationValue * 2 * pi);
      final animatedOpacity = (particle.baseOpacity + pulse * 0.3).clamp(
        0.5,
        0.9,
      );

      particlePaint.shader = RadialGradient(
        colors: [
          // ignore: deprecated_member_use
          Colors.cyan[300]!.withOpacity(animatedOpacity),
          // ignore: deprecated_member_use
          Colors.purple[900]!.withOpacity(animatedOpacity * 0.5),
        ],
      ).createShader(
        Rect.fromCircle(center: particle.position, radius: particle.radius * 2),
      );
      canvas.drawCircle(particle.position, particle.radius, particlePaint);
    }

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];
        final distance = (p1.position - p2.position).distance;
        if (distance < 150) {
          final lineOpacity = (1 - distance / 150) * 0.4;
          linePaint.shader = LinearGradient(
            colors: [
              // ignore: deprecated_member_use
              Colors.cyan[300]!.withOpacity(lineOpacity),
              // ignore: deprecated_member_use
              Colors.purple[900]!.withOpacity(lineOpacity),
            ],
          ).createShader(Rect.fromPoints(p1.position, p2.position));
          canvas.drawLine(p1.position, p2.position, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class InputTab extends StatefulWidget {
  const InputTab({super.key});

  @override
  InputTabState createState() => InputTabState();
}

class InputTabState extends State<InputTab> {
  final TextEditingController controller = TextEditingController();
  String _selectedLanguage = 'Dart';
  final List<String> _languages = [
    'Dart',
    'Python',
    'JavaScript',
    'Java',
    'C++',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BounceInDown(
                duration: const Duration(milliseconds: 1000),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CodeCraft AI',
                          style: GoogleFonts.orbitron(
                            color: Colors.purple[800],
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ZoomIn(
                          duration: const Duration(milliseconds: 800),
                          child: DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(
                              labelText: 'Select Language',
                              filled: true,
                              // ignore: deprecated_member_use
                              fillColor: Colors.white.withOpacity(0.85),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.cyan[300]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            // ignore: deprecated_member_use
                            dropdownColor: Colors.white.withOpacity(0.9),
                            style: GoogleFonts.orbitron(
                              color: Colors.purple[800],
                            ),
                            iconEnabledColor: Colors.cyan[300],
                            items:
                                _languages
                                    .map(
                                      (lang) => DropdownMenuItem(
                                        value: lang,
                                        child: Text(lang),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ZoomIn(
                          duration: const Duration(milliseconds: 900),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Ask a coding question',
                                hintText:
                                    'e.g., "Write a $_selectedLanguage function for wind speed"',
                                prefixIcon: Icon(
                                  Icons.code,
                                  color: Colors.purple[600],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.cyan[300]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                              maxLines: 4,
                              style: GoogleFonts.orbitron(
                                color: Colors.purple[800],
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElasticInUp(
                          duration: const Duration(milliseconds: 1100),
                          child: BlocBuilder<CodeBloc, CodeState>(
                            builder: (context, state) {
                              return AnimatedButton(
                                onPressed:
                                    state.isLoading ||
                                            controller.text.trim().isEmpty
                                        ? null
                                        : () {
                                          BlocProvider.of<CodeBloc>(
                                            context,
                                          ).add(
                                            ProcessCodeEvent(
                                              controller.text,
                                              _selectedLanguage,
                                            ),
                                          );
                                        },
                                child: const Text('Generate'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BounceInUp(
                duration: const Duration(milliseconds: 1200),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: BlocBuilder<CodeBloc, CodeState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Response',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.w600,
                                color: Colors.purple[800],
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (state.isLoading)
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                period: const Duration(milliseconds: 1500),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            else if (state.error != null)
                              Text(
                                'Error: ${state.error}',
                                style: GoogleFonts.orbitron(
                                  color: Colors.red[600],
                                  fontSize: 16,
                                ),
                              )
                            else if (state.output != null)
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  state.output!,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.purple[800],
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // ignore: deprecated_member_use
            Colors.white.withOpacity(0.2),
            // ignore: deprecated_member_use
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.cyan[300]!.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.purple[200]!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: child,
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AnimatedButton({super.key, this.onPressed, required this.child});

  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.95;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
        if (widget.onPressed != null) widget.onPressed!();
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[300],
            foregroundColor: Colors.purple[800],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            // ignore: deprecated_member_use
            shadowColor: Colors.cyan[200]!.withOpacity(0.4),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
