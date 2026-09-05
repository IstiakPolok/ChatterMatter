import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../core/api_handler.dart';
import '../../env.dart';
import '../model/subscription_model.dart';

class SubscriptionRepo {
  /// journal repo
  Future<Attempt<SubscriptionPackages>> getPackages() async {
    try {
      final url = Uri.parse('$baseUrl/getPackages');

      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      if (response.statusCode == 200 || response.statusCode == 201) {
        return success(
          SubscriptionPackages.fromJson(jsonDecode(response.body)),
        );
      } else if (response.statusCode == 401) {
        return failed(SessionExpired());
      } else if (response.statusCode == 403) {
        return failed(UnauthorizeAccess());
      }
      return failed(Failure(title: "Something went wrong"));
    } on http.ClientException catch (e) {
      return failed(Failure(title: e.message));
    } on FormatException catch (e) {
      return failed(Failure(title: e.message));
    } on Exception catch (e) {
      return failed(Failure(title: e.toString()));
    }
  }

  // createPayment

  Future<Attempt<String>> createPaymentSession({
    required String subscriptionId,
    required String planDurationType,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      final response = await http.post(
        Uri.parse('$baseUrl/createCheckoutSession'),
        body: jsonEncode({
          'subscriptionId': subscriptionId,
          'email': 'uyu@g.com',
          "planDurationType": planDurationType,
        }),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return success(data['url']);
      }
      return failed(Failure(title: data["error"]));
    } catch (e) {
      return failed(Failure(title: e.toString()));
    }
  }

  //confirm payment

  // await Stripe.instance.confirmPayment(
  //   clientSecret,
  //   PaymentMethodParams.card(
  //     paymentMethodData: PaymentMethodData(),
  //   ),
  // );

  /// Update subscription in backend after RevenueCat purchase
  Future<void> updateSubscriptionInBackend({
    required String subscriptionId,
    required String planDurationType,
    required num price,
    String? transactionId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final token = await user.getIdToken(true);

    final body = <String, dynamic>{
      'subscriptionId': subscriptionId,
      'planDurationType': planDurationType,
      'price': price,
      if (transactionId != null) 'transactionId': transactionId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/updateSubscription'),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Backend sync failed: ${response.statusCode} ${response.body}');
    }
  }

  ///add journal
  /// Log detailed transaction data to backend
  Future<void> addTransaction({
    required String plan,
    required num cost,
    required String time,
    required String store,
    required String currency,
    required String transactionId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken(true);

    final response = await http.post(
      Uri.parse('$baseUrl/addTransaction'),
      body: jsonEncode({
        'plan': plan,
        'cost': cost,
        'time': time,
        'store': store,
        'currency': currency,
        'transactionId': transactionId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    debugPrint('ADD_TRANSACTION STATUS: ${response.statusCode}');
    debugPrint('ADD_TRANSACTION RESPONSE: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
       // Silent failure or log
    }
  }
}
