import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/custom_buttons.dart';
import 'package:chatter_matter_app/common/custom_input.dart';
import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/common/snack_bar.dart';
import 'package:chatter_matter_app/common/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/gradiant_background.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool isLoading = false;
  String email = "email@gmail.com";
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      showGlobalOverlayToast(
        context: context,
        message:
            'Password reset email sent. Please check your inbox or spam folder.',
        type: ToastType.success,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Something went wrong')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: customGradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Form(
            key: _formKey,
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
                  hintText: "Enter your email",
                  isEnable: !isLoading,
                  onChange: (e) => email = e,
                  validator: CommonValidator.emailValidator,
                ),
                vPad35,
                customFilledButton(
                  title: "Next",
                  onTap: () async => await _resetPassword(),
                  isLoading: isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
