// ai_one_flutter/lib/screens/splash_screen.dart
import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _zoomController; // New zoom animation controller
  late Animation<double> _zoomAnimation; // New zoom animation

  @override
  void initState() {
    super.initState();

    // Fade animation for the whole content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Rotate animation for the logo
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Zoom animation for the image
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust zoom speed here
    )..repeat(reverse: true); // Zoom in and out
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.2).animate( // Adjust zoom level here
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadDataAndNavigate();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    _zoomController.dispose(); // Dispose the zoom controller
    super.dispose();
  }

  Future<void> _loadDataAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    await Future.wait([
      Provider.of<ContactViewModel>(context, listen: false).fetchContacts(),
      Provider.of<NoteViewModel>(context, listen: false).fetchNotes(),
      Provider.of<CredentialViewModel>(context, listen: false).fetchCredentials(),
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks(),
    ]);

    await Future.delayed(
        _fadeController.duration! + const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283593), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_rotateController, _zoomController]), // Animate both rotate and zoom
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _zoomAnimation.value, // Apply zoom
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container( // Wrap the image in a container for the circle
                          width: 180,  // Match the original size
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Make it a circle
                            image: DecorationImage(
                              image: AssetImage('assets/images/ai1.png'),
                              fit: BoxFit.cover, // Cover the circle
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Text(
                  'AI One',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                  strokeWidth: 4.0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Chargement des données...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Veuillez patienter',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}