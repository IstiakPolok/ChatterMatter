import 'package:chatter_matter_app/firebase_options.dart';
import 'package:chatter_matter_app/presentation/home/home_view.dart';
import 'package:chatter_matter_app/providers/dashboard_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'application/firebase/notification_service.dart';
import 'application/user/auth_bloc.dart';
import 'env.dart';
import 'presentation/onbording/splash_screen.dart';
import 'providers/journal_provider.dart';
import 'providers/question_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Mobile Ads
  await MobileAds.instance.initialize();

  await PurchasesApi.init();

  // Initialize notifications
  final notification = NotificationService();
  await notification.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserBloc()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => JournalProvider()),
        ChangeNotifierProvider(create: (context) => QuestionProvider()),
      ],
      child: MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
