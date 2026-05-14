import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/api_handler.dart';
import '../../env.dart';
import '../model/journal_model.dart';

class JournalRepo {
  /// journal repo
  Future<Attempt<JournalPaginator>> getJournals({
    int limit = 10,
    String? pageToken,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      // final url = Uri.parse("$baseUrl/getJournals");

      final url = Uri.parse('$baseUrl/getJournals').replace(
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
        return success(JournalPaginator.fromJson(jsonDecode(response.body)));
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

  ///add journal
  Future<Attempt<Journal>> addJournal(Journal data) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return failed(SessionExpired());

      final token = await user.getIdToken(true);

      final url = Uri.parse("$baseUrl/addJournal");

      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(data.toJson()),
          )
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      if (response.statusCode == 200 || response.statusCode == 201) {
        return success(Journal.fromJson(jsonDecode(response.body)["data"]));
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

  ///delete journal
  Future<Attempt<bool>> deleteJournal(String journalId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('JournalRepo: Delete failed - No user logged in.');
        return failed(SessionExpired());
      }

      final token = await user.getIdToken(true);

      // Support query parameter as 'journalId' and 'id'
      final url = Uri.parse(
        "$baseUrl/deleteJournal?journalId=$journalId&id=$journalId",
      );
      debugPrint('JournalRepo: Sending DELETE request to: $url');
      debugPrint('token = $token');
      debugPrint('journalId = $journalId');

      final response = await http
          .delete(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"journalId": journalId}),
          )
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      debugPrint(
        'JournalRepo: DELETE response status code: ${response.statusCode}',
      );
      debugPrint('JournalRepo: DELETE response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return success(true);
      } else if (response.statusCode == 401) {
        debugPrint('JournalRepo: 401 Session Expired');
        return failed(SessionExpired());
      } else if (response.statusCode == 403) {
        debugPrint('JournalRepo: 403 Unauthorized Access');
        return failed(UnauthorizeAccess());
      }
      debugPrint(
        'JournalRepo: Delete failed with unexpected status code ${response.statusCode}',
      );
      return failed(Failure(title: "Something went wrong"));
    } on http.ClientException catch (e) {
      debugPrint('JournalRepo: ClientException: ${e.message}');
      return failed(Failure(title: e.message));
    } on FormatException catch (e) {
      debugPrint('JournalRepo: FormatException: ${e.message}');
      return failed(Failure(title: e.message));
    } on Exception catch (e) {
      debugPrint('JournalRepo: Exception: $e');
      return failed(Failure(title: e.toString()));
    }
  }
}
