import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';

import '../../application/user/auth_bloc.dart';
import '../../common/gradiant_background.dart';
import '../../common/navigator.dart';

import '../landing/landing_view.dart';
import 'start_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isDownloadingUpdate = false;
  final _updater = ShorebirdUpdater();

  void checkUserState() async {
    // Check for Shorebird updates first
    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        if (mounted) {
          setState(() {
            _isDownloadingUpdate = true;
          });
        }
        await _updater.update();
        await Restart.restartApp();
        return; // Stop navigation, wait for restart
      }
    } catch (e) {
      debugPrint('Shorebird update check failed: $e');
    }

    Future.delayed(const Duration(seconds: 1)).then((e) async {
      if (!mounted) return;

      final check = await Provider.of<UserBloc>(
        context,
        listen: false,
      ).retrieveUser();
      if (check && mounted) {
        animatedNavigateReplaceAll(context, const LandingView());
      } else if (check == false && mounted) {
        animatedNavigateReplaceAll(context, const StartScreen());
      }
    });
  }

  @override
  void initState() {
    checkUserState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: customGradientBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(child: Image.asset("assets/image/brand_logo.png")),
            ),

            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isDownloadingUpdate) ...[
                      const Text(
                        'Downloading Update...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
