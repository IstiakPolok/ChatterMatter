import 'dart:io';

import 'package:chatter_matter_app/core/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/api_handler.dart';
import '../model/user_model.dart';
import '../repo/dashboard_repo.dart';
import '../repo/question_repo.dart';
import 'auth_repo.dart';

class UserBloc extends ChangeNotifier {
  UserBloc() {
    init();
  }
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  User? user;
  AppUser? profile;
  bool isLoadingProfile = false;
  bool isLoadingNotification = false;
  bool isUpdatingPassword = false;

  final _authRepo = AuthRepo();
  final dashboardRepo = DashboardRepo();
  final questionRepo = QuestionRepo();

  void init() async {
    retrieveUser();
    await _authRepo.updateLastVisit();
    // await fetchProfile();
  }


  void updatesubscription(SubscriptionType type) {
  if (profile == null) return;

  // profile!.subscriptionType = type;
  profile=profile!.copyWith(subscriptionType :type);

  debugPrint("Subscription updated to: $type");

  notifyListeners(); // 🔥 This rebuilds HomeView instantly
}

  Future<bool> retrieveUser() async {
    try {
      final data = FirebaseAuth.instance.currentUser;

      profile = null;
      if (data != null) {
        await Purchases.logIn(data.uid);
      }
      final check = await fetchProfile();
      if (data != null && check != null) {
        user = data;
        notifyListeners();
        return true;
      } else {
        user = null;
        profile = null;
        await logout();
        notifyListeners();
        return false;
      }
    } catch (e) {
      user = null;
      profile = null;
      notifyListeners();
      return false;
    }
  }

  Future<Attempt<User>> login({
    required String email,
    required String password,
  }) async {
    final (data, error) = await _authRepo.loginWithEmail(
      email: email,
      password: password,
    );
    if (data != null) {
      user = data;
      await Purchases.logIn(data.uid);
      await fetchProfile();
    }

    notifyListeners();
    await _authRepo.updateLastVisit();
    return (data, error);
  }

  Future<Attempt<User>> register({
    required String email,
    required String password,
  }) async {
    final (data, error) = await _authRepo.registerWithEmail(
      email: email,
      password: password,
    );
    if (data != null) {
      user = data;
      await Purchases.logIn(data.uid);
      await _authRepo.updateLastVisit();
      await fetchProfile();
    }
    notifyListeners();
    return (data, error);
  }

  Future<AppUser?> fetchProfile() async {
    isLoadingProfile = true;
    profile = null;
    notifyListeners();
    final (data, error) = await _authRepo.getProfile();
    if (data != null) {
      profile = data;
    } else {
      profile = null;
    }
    isLoadingProfile = false;
    notifyListeners();
    return data;
  }

  Future updateNotification(bool v) async {
    isLoadingNotification = true;
    notifyListeners();

    // attempt

    profile?.pushNotification = v;
    isLoadingNotification = false;
    notifyListeners();
  }

  Future<Attempt<String>> changePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    final (data, error) = await _authRepo.changePassword(
      newPass: newPassword,
      oldPass: oldPassword,
    );

    return (data, error);
  }

  Future<bool> forgatPassword({required String email}) async {
    return false;
  }

  Future<Attempt<String>> updateProfile({
    File? image,
    String? name,
    int? age,
  }) async {
    final (data, error) = await _authRepo.updateProfile(
      name: name,
      image: image,
      age: age,
    );
    if (data != null) {
      profile = data;
      notifyListeners();
      return success("successfully Updated the profile");
    } else {
      return failed(error!);
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    await Purchases.logOut();
    user = null;
    profile = null;
    notifyListeners();
  }

  Future<Attempt<String>> deleteAccount(String val) async {
    final (data, error) = await _authRepo.deleteAccount(val);
    if (data != null) {
      logout();
    }
    return (data, error);
  }

  Future<Attempt<String>> updataSelectedCategory(String catsId) async {
    // if (profile?.subscriptionType == SubscriptionType.standard) {
    //   if (profile?.selectedCategories.length == 3 &&
    //       !profile!.selectedCategories.contains(catsId)) {
    //     return failed(
    //       Failure(
    //         title: "Category Length must be under 3. Please unselect one.",
    //       ),
    //     );
    //   } else {
    //     profile!.selectedCategories.add(catsId);
    //   }
    // }

    if (profile?.subscriptionType == SubscriptionType.vip) {
      return success("Yuo are already a vip user You have all category access");
    }

    // final (check)
    final (check, error) = await dashboardRepo.updateSelectedCategory([catsId]);
    if (check != null) {
      profile?.selectedCategories = [catsId];
      notifyListeners();
    }

    return (check, error);
    // final data=await
  }

  Future<void> addFavQuestion(String id) async {
    final (dd, e) = await questionRepo.toggleFavoriteQuestion(id);
    if (dd == true) {
      profile?.favoriteQuestionIds.add(id);
    }
    if (dd == false) {
      profile?.favoriteQuestionIds.remove(id);
    }

    notifyListeners();
  }

  final List<String> scopes = <String>['email', 'profile'];

  void googleSetup() async {
    // Initialize with your Web Client ID
    googleSignIn.initialize(
      serverClientId:
          "196013058870-fsk4e9f56ph3g4331751hkt8bb8525h8.apps.googleusercontent.com",
    );
    googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    // #docregion CheckAuthorization
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);
    // #enddocregion CheckAuthorization

    // setState(() {
    //   _currentUser = user;
    //   _isAuthorized = authorization != null;
    //   _errorMessage = '';
    // });

    // If the user has already granted access to the required scopes, call the
    // REST API.
    if (user != null && authorization != null) {
      // unawaited(_handleGetContact(user));
      print(user);
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    print(e);
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final googleAuth = await googleSignIn.authenticate();
      // User cancelled

      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.authentication.idToken,
      );

      // googleCredential.idToken;

      // backend post api/

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Attempt to link Google to existing Firebase user
        try {
          await currentUser.linkWithCredential(googleCredential);
          await fetchProfile();
          return currentUser;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked') {
            // Already linked → just return current user
            await fetchProfile();
            return currentUser;
          } else if (e.code == 'credential-already-in-use') {
            // Google account is linked to another Firebase UID
            print('Google account already linked with another user.');
            return null;
          }
          rethrow;
        }
      } else {
        // Sign in with Google (new or returning user)
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          googleCredential,
        );
        await fetchProfile();
        return userCredential.user;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        print('Google Sign-In cancelled by user.');
        return null;
      }
      print('GoogleSignInException: ${e.code} ');
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      print('Google Sign-In failed: $e');
      return null;
    }
  }

  // APPLE SIGN IN

  Future<User?> signInWithApple() async {
    try {
      // request Apple ID credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // create an OAuth credential
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final currentUser = FirebaseAuth.instance.currentUser;

      // sign in with the credential
      if (currentUser != null) {
        // Attempt to link Google to existing Firebase user
        try {
          await currentUser.linkWithCredential(oAuthCredential);
          await fetchProfile();
          return currentUser;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked') {
            // Already linked → just return current user
            await fetchProfile();
            return currentUser;
          } else if (e.code == 'credential-already-in-use') {
            // Google account is linked to another Firebase UID
            print('Google account already linked with another user.');
            return null;
          }
          rethrow;
        }
      } else {
        // Sign in with Google (new or returning user)
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          oAuthCredential,
        );
        await fetchProfile();
        return userCredential.user;
      }

      // AppUser appUser = AppUser(
      //   uid: firebaseUser.uid,
      //   email: firebaseUser.email ?? '',
      // );
    } catch (e) {
      print("Error signing in with apple: $e");
      return null;
    }
  }
}
