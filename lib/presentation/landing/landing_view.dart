import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../application/user/auth_bloc.dart';
import '../../common/gradiant_background.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/question_provider.dart';
import '../explore/explore_view.dart';
import '../home/home_view.dart';
import '../journal/journal_view.dart';
import '../setting/settings_view.dart';
import '../setting/showcase_keys.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  int _selectedIndex = 0;
  BuildContext? _showcaseContext;

  // final children = [HomeView(), ExploreView(), JournalView(), SettingsView()];
  final children = [HomeView(), JournalView(), SettingsView()];

  bool _hasShownInstructionsThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstTimeInstructionsIfNeeded();
    });
  }

  Future<void> _showFirstTimeInstructionsIfNeeded() async {
    if (_hasShownInstructionsThisSession) return;

    final userBloc = context.read<UserBloc>();
    final profile = userBloc.profile;

    if (profile == null) {
      // Wait until profile is loaded
      return;
    }

    _hasShownInstructionsThisSession = true;

    final prefs = await SharedPreferences.getInstance();
    final hasShownTour = prefs.getBool('has_shown_welcome_tour_v1') ?? false;

    if (!hasShownTour || profile.totalVisited <= 1) {
      _showWelcomeInstructionsDialog();
    }
  }

  void _startTutorial() {
    if (_showcaseContext != null) {
      ShowCaseWidget.of(_showcaseContext!).startShowCase([
        ShowcaseKeys.settingsTabKey,
        ShowcaseKeys.ageGroupKey,
        ShowcaseKeys.subscriptionKey,
        ShowcaseKeys.categoriesKey,
        ShowcaseKeys.saveJournalKey,
      ]);
    }
  }

  void _showWelcomeInstructionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white.withOpacity(0.9),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF5E6C8), Color(0xFFE8D5F0)],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome! 🎉",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D1B4E),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Would you like a quick interactive tour on how to get the most out of Chatter Matters?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3A6A),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('has_shown_welcome_tour_v1', true);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xFF8B6BBD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B6BBD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('has_shown_welcome_tour_v1', true);
                        if (context.mounted) {
                          Navigator.pop(context);
                          _startTutorial();
                        }
                      },
                      child: const Text(
                        "Show Me",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UserBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showFirstTimeInstructionsIfNeeded();
      }
    });

    return ShowCaseWidget(
      onComplete: (index, key) {
        if (key == ShowcaseKeys.settingsTabKey) {
          setState(() {
            _selectedIndex = 2;
          });
        } else if (key == ShowcaseKeys.subscriptionKey) {
          setState(() {
            _selectedIndex = 0;
          });
          // Programmatically select category if none is selected
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final userBloc = context.read<UserBloc>();
              final dashboardProvider = context.read<DashboardProvider>();
              if (userBloc.profile?.selectedCategories.isEmpty ?? true) {
                if (dashboardProvider.categoryList.isNotEmpty) {
                  final firstCatId = dashboardProvider.categoryList.first.id;
                  userBloc.updateSelectedCategory(firstCatId);
                  context.read<QuestionProvider>().resetWithCategories([
                    firstCatId,
                  ]);
                }
              }
            }
          });
        } else if (key == ShowcaseKeys.saveJournalKey) {
          setState(() {
            _selectedIndex = 1;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted && _showcaseContext != null) {
                ShowCaseWidget.of(
                  _showcaseContext!,
                ).startShowCase([ShowcaseKeys.journalPageKey]);
              }
            });
          });
        }
      },
      builder: (context) {
        _showcaseContext = context;
        return Scaffold(
          body: customGradientBackgroundWithSvg(
            child: children[_selectedIndex],
          ),

          bottomNavigationBar: Showcase(
            key: ShowcaseKeys.settingsTabKey,
            title: "⚙️ Step 1 — Start in Settings",
            description: "Tap the Settings wheel at the bottom of your screen.",
            tooltipBackgroundColor: const Color(0xFF8B6BBD),
            textColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            descTextStyle: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            child: Container(
              color: const Color(0xff7F4DA3),
              padding: EdgeInsets.all(defaultPadding),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: customDarkPurple,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: customWhite,
                tabs: const [
                  GButton(icon: Icons.home, text: 'Home'),
                  // GButton(icon: Icons.explore, text: 'Explore'),
                  GButton(icon: Icons.menu_book_sharp, text: 'Journal'),
                  GButton(icon: Icons.settings, text: 'Settings'),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
