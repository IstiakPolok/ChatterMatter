import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/api_handler.dart';
import '../../env.dart';
import '../model/question_model.dart';

class QuestionRepo {
  /// journal repo
  Future<Attempt<QuestionPaginator>> getVipQuestions({
    int limit = 10,
    String? pageToken,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      // final url = Uri.parse("$baseUrl/getJournals");

      final url = Uri.parse('$baseUrl/getQuestionPaginator').replace(
        queryParameters: {
          'limit': "10",
          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      final response = await http
          .get(
            url,

            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      if (response.statusCode == 200 || response.statusCode == 201) {
        return success(QuestionPaginator.fromJson(jsonDecode(response.body)));
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

  /// journal repo
  Future<Attempt<QuestionPaginator>> getQuestionSet({
    int limit = 10,
    String? pageToken,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      // final url = Uri.parse('$baseUrl/getQuestionPaginator').replace(
      final url = Uri.parse('$baseUrl/getQuestions2').replace(
        queryParameters: {
          'limit': '10',
          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(jsonDecode(response.body));
        return success(QuestionPaginator.fromJson(jsonDecode(response.body)));
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

  /// journal repo
  Future<Attempt<QuestionPaginator>> getQuestionsByCategory({
    int limit = 10,
    String? pageToken,
    required String categoryId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      final url = Uri.parse('$baseUrl/getQuestionsByCategory').replace(
        queryParameters: {
          if (limit > 0) 'limit': limit.toString(),
          'categoryId': categoryId,
          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      debugPrint('QuestionRepo: getQuestionsByCategory URL -> $url');

      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('QuestionRepo: API Response for getQuestionsByCategory: ${response.body}');
        return success(QuestionPaginator.fromJson(jsonDecode(response.body)));
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

  Future<Attempt<bool>> toggleFavoriteQuestion(String qId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      // final url = Uri.parse("$baseUrl/getJournals");

      final url = Uri.parse('$baseUrl/updateFavoriteCount');
      debugPrint("DEBUG: Toggling favorite API -> $url");

      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"questionId": qId}),
          )
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(jsonDecode(response.body));
        debugPrint("DEBUG: Toggle favorite API success. Added: ${jsonDecode(response.body)["added"]}");
        return success(jsonDecode(response.body)["added"]);
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
}
