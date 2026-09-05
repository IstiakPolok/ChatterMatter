import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:chatter_matter_app/common/navigator.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/presentation/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/colors.dart';
import '../../common/custom_buttons.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset("assets/image/start.png", fit: BoxFit.cover),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/startingIcon.svg"),
                      Text(
                        "Chatter Matters",
                        style: bodyLarge(color: customLightPurple),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    Text(
                      "Say More!",
                      style: headingLarge(color: customLightPurple),
                    ),
                    vPad10,
                    Text(
                      "Simple question, deeper connections",
                      style: bodyLarge(color: customLightGray),
                    ),
                    vPad35,
                    customFilledButton(
                      onTap: () {
                        animatedNavigateReplaceAll(context, LoginView());
                      },
                      isLoading: false,
                      title: "Get Started",
                      width: double.infinity,
                    ),
                    vPad15,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
