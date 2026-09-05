// ignore_for_file: override_on_non_overriding_member

import 'package:chatter_matter_app/presentation/auth/login_view.dart';
import 'package:flutter/material.dart';

import '../../common/colors.dart';
import '../../common/custom_buttons.dart';
import '../../common/custom_input.dart';
import '../../common/custom_text_style.dart';
import '../../common/gradiant_background.dart';
import '../../common/navigator.dart';
import '../../common/padding.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  bool isLoading = false;
  String email = "email@gmail.com";

  bool visiblePassword = false;
  bool visibleConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: customGradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: primaryBackButton(context: context),
              ),
              vPad35,
              Text("Forgot Password", style: heading()),
              Text(
                "Enter the required details",
                style: bodyMedium(color: customGray),
              ),
              vPad35,
              vPad20,
              customInput(
                hintText: "Password",
                isEnable: !isLoading,
                onChange: (e) {},
                onVisible: () => setState(() {
                  visiblePassword = !visiblePassword;
                }),
                visible: !visiblePassword,
              ),
              vPad20,
              customInput(
                hintText: "Confirm Password",
                isEnable: !isLoading,
                onChange: (e) {},
                onVisible: () => setState(() {
                  visibleConfirmPassword = !visibleConfirmPassword;
                }),
                visible: !visibleConfirmPassword,
              ),
              vPad35,
              customFilledButton(
                title: "Reset Password",
                onTap: () => animatedNavigateReplaceAll(context, LoginView()),
                isLoading: isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
