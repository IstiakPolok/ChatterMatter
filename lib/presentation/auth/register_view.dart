// ignore_for_file: override_on_non_overriding_member

import 'package:chatter_matter_app/presentation/auth/login_view.dart';
import 'package:chatter_matter_app/presentation/landing/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/user/auth_bloc.dart';
import '../../application/user/auth_repo.dart';
import '../../common/colors.dart';
import '../../common/custom_buttons.dart';
import '../../common/custom_input.dart';
import '../../common/custom_text_style.dart';
import '../../common/gradiant_background.dart';
import '../../common/navigator.dart';
import '../../common/padding.dart';
import '../../common/validator.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  bool isLoading = false;
  String email = "email@gmail.com";
  String password = "";
  String confirmPassword = "";
  String name = "";
  bool visiblePassword = false;
  bool visibleConfirmPassword = false;
  final _formKey = GlobalKey<FormState>();

  final auth = AuthRepo();

  void register() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final (data, error) = await Provider.of<UserBloc>(
      context,
      listen: false,
    ).register(email: email.trim(), password: password.trim());

    if (data != null) {
      animatedNavigateReplaceAll(context, LandingView());
    }

    if (error != null) {
      print("❌ Registration error: ${error.title}");
    } else {
      print("✅ Registration successful!");
    }

    setState(() {
      isLoading = false;
    });
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
                SizedBox(
                  width: 150,
                  child: Image.asset("assets/image/brand_logo.png"),
                ),
                vPad35,
                Text("Sign Up", style: heading()),
                vPad5,
                Text(
                  "Chatter Matters by Veenu Inspires",
                  style: bodyMedium(color: customLightGray),
                ),
                vPad35,
                vPad20,
                // customInput(
                //   hintText: "Enter your name",
                //   isEnable: !isLoading,
                //   onChange: (e) {},
                // ),
                // vPad15,
                customInput(
                  hintText: "Enter your email",
                  isEnable: !isLoading,
                  onChange: (e) => email = e,
                  validator: (e) => CommonValidator.emailValidator(e),
                ),
                vPad15,
                customInput(
                  hintText: "Password",
                  isEnable: !isLoading,
                  validator: (e) => CommonValidator.passwdValidator(e),
                  onChange: (e) => password = e,
                  onVisible: () => setState(() {
                    visiblePassword = !visiblePassword;
                  }),
                  visible: !visiblePassword,
                ),
                vPad15,
                customInput(
                  hintText: "Confirm Password",
                  isEnable: !isLoading,
                  onChange: (e) => confirmPassword = e,
                  onVisible: () => setState(() {
                    visibleConfirmPassword = !visibleConfirmPassword;
                  }),
                  visible: !visibleConfirmPassword,
                  validator: (e) => CommonValidator.confirmPasswdValidator(
                    pass: password,
                    val: e,
                  ),
                ),
                vPad15,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 2,
                  children: [
                    Checkbox(value: true, onChanged: (e) {}),

                  Expanded(child: Wrap(
                    runSpacing: 4,
                    spacing: 4,
                    children: [
                      Text("I agree the"),
                    Text(
                      "User Agreement",
                      style: bodyMedium(color: customGreen),
                    ),
                    Text("and"),
                    Text(
                      "Privacy Policy.",
                      style: bodyMedium(color: customGreen),
                    ),
                  ],))
                  ],
                ),
                vPad35,
                customFilledButton(
                  title: "Sign Up",
                  onTap: () => register(),
                  isLoading: isLoading,
                  width: double.infinity,
                ),

                vPad35,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // spacing: 4,
                  children: [
                    Text("Already have any account?"),
                    TextButton(
                      onPressed: () {
                        animatedNavigateReplace(context, LoginView());
                      },
                      child: Text(
                        "Login",
                        style: bodyMedium(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
