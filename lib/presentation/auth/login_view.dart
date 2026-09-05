
import 'dart:io';

import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/custom_buttons.dart';
import 'package:chatter_matter_app/common/custom_input.dart';
import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:chatter_matter_app/common/navigator.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/common/snack_bar.dart';
import 'package:chatter_matter_app/common/validator.dart';
import 'package:chatter_matter_app/presentation/auth/forget_password.dart';
import 'package:chatter_matter_app/presentation/auth/register_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/user/auth_bloc.dart';
import '../landing/landing_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";

  void login() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    final (data, error) = await Provider.of<UserBloc>(
      context,
      listen: false,
    ).login(email: email.trim(), password: password.trim());

    if (data != null) {
      showToast(
        context: context,
        title: "Successfully logged In",
        toastType: ToastType.success,
      );

      animatedNavigateReplaceAll(context, LandingView());
    } else {
      showToast(
        context: context,
        title: error?.title ?? "",
        toastType: ToastType.failed,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    final check = await Provider.of<UserBloc>(
      context,
      listen: false,
    ).signInWithGoogle();
    if (!mounted) return;
    if (mounted && check != null) {
      showToast(
        context: context,
        title: "Successfully logged In",
        toastType: ToastType.success,
      );

      animatedNavigateReplaceAll(context, LandingView());
    } else {
      showToast(
        context: context,
        title: "Unable to sign in",
        toastType: ToastType.failed,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void loginWithApple() async {
    setState(() {
      isLoading = true;
    });
    final check = await Provider.of<UserBloc>(
      context,
      listen: false,
    ).signInWithApple();

    if (check != null && context.mounted) {
      showToast(
        context: context,
        title: "Successfully logged In",
        toastType: ToastType.success,
      );

      animatedNavigateReplaceAll(context, LandingView());
    } else {
      showToast(
        context: context,
        title: "Unable to sign in",
        toastType: ToastType.failed,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    Provider.of<UserBloc>(context, listen: false).googleSetup();
    super.initState();
  }

  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/image/customGradiantBg.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      vPad35,
                      SizedBox(
                        width: 150,
                        child: Image.asset("assets/image/brand_logo.png"),
                      ),
                      vPad35,
                      Text("Login", style: heading()),
                      vPad5,
                      Text(
                        "Chatter Matters by Veenu Inspires",
                        style: bodyMedium(color: customLightGray),
                      ),
                      vPad35,

                      customInput(
                        hintText: "User Email",
                        isEnable: !isLoading,
                        validator: CommonValidator.emailValidator,
                        onChange: (e) {
                          email = e;
                        },
                      ),
                      vPad15,
                      customInput(
                        visible: visible,
                        onVisible: () => setState(() {
                          visible = !visible;
                        }),
                        hintText: "Password",
                        isEnable: !isLoading,
                        validator: (e) => CommonValidator.passwdValidator(e),
                        onChange: (e) {
                          password = e;
                        },
                      ),
                      // vPad10,
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () =>
                              animatedNavigateTo(context, ForgetPassword()),
                          child: Text(
                            "Forgot Password?",
                            style: bodyMedium(color: customGray),
                          ),
                        ),
                      ),
                      vPad35,

                      customFilledButton(
                        title: "Log In",
                        onTap: () => login(),
                        isLoading: isLoading,
                        width: double.infinity,
                      ),
                      vPad35,
                      Row(
                        children: [
                          Expanded(
                            child: Divider(endIndent: 10, color: customGray),
                          ),
                          Text("Or", style: bodyLarge(color: customDarkGray)),
                          Expanded(
                            child: Divider(indent: 10, color: customGray),
                          ),
                        ],
                      ),
                      vPad35,
                      if (Platform.isAndroid)
                        googleLoginButton(
                          onTap: () async => loginWithGoogle(),
                          isLoading: isLoading,
                        ),
                      if (Platform.isIOS)
                        Column(
                          children: [
                            vPad20,
                            appleLoginButton(
                              onTap: () => loginWithApple(),
                              isLoading: isLoading,
                            ),
                          ],
                        ),

                      vPad20, vPad5,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // spacing: 4,
                        children: [
                          Text("Don’t have any account?"),
                          TextButton(
                            onPressed: () {
                              animatedNavigateReplace(context, RegisterView());
                            },
                            child: Text(
                              "Sign Up",
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
          ),
        ],
      ),
    );
  }
}
