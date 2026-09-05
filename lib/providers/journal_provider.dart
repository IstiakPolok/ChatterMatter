import 'package:flutter/material.dart';

import '../application/model/journal_model.dart';
import '../application/repo/journal_repo.dart';
import '../core/api_handler.dart';

class JournalProvider extends ChangeNotifier {
  JournalProvider() {
    init();
  }
  bool isLoading = false;
  bool isPaginating = false;
  bool reachEnd = false;
  bool addingHomeJournal = false;
  bool addingJournal = false;

  final JournalRepo _journalRepo = JournalRepo();

  JournalPaginator? journalPaginator;
  List<Journal> journalList = [];

  init() async {
    getJournal();
  }

  void resetPaginator() async {
    journalPaginator = null;
    journalList = [];
    getJournal();
  }

  void getJournal() async {
    if (journalPaginator == null) {
      isLoading = true;
    } else {
      isPaginating = true;
    }
    if (journalPaginator != null && journalPaginator?.pageToken == null) {
      reachEnd = true;
      return;
    }
    notifyListeners();

    final (data, error) = await _journalRepo.getJournals();

    if (data != null) {
      debugPrint('JournalProvider: Successfully fetched journals. Response Body JSON: ${data.toJson()}');
      journalList.addAll(data.data);
      debugPrint('JournalProvider: Successfully fetched ${data.data.length} journals. Total list size is now: ${journalList.length}');
    } else {
      debugPrint('JournalProvider: Failed to fetch journals. Error: ${error?.title ?? "Unknown error"}');
    }

    isLoading = false;
    isPaginating = false;
    notifyListeners();
  }

  Future<Attempt<Journal>> addJournal({
    bool isHome = false,
    required String question,
    required String questionId,
    required String ans,
  }) async {
    if (isHome) {
      addingHomeJournal = true;
    } else {
      addingJournal = true;
    }

    notifyListeners();

    final (data, error) = await _journalRepo.addJournal(
      Journal(
        ans: ans,
        question: question,
        createdAt: "",
        id: "",
        uid: "",
        questionId: questionId,
      ),
    );

    if (data != null) {
      journalList.insert(0, data);
    }

    addingJournal = false;
    addingHomeJournal = false;
    notifyListeners();
    return (data, error);
  }

  Future<bool?> deleteJournal({required String journalId}) async {
    debugPrint('JournalProvider: Deleting journal with ID: $journalId');
    notifyListeners();

    final (data, error) = await _journalRepo.deleteJournal(journalId);

    if (data != null) {
      final oldLength = journalList.length;
      journalList.removeWhere((t) => t.id == journalId);
      debugPrint('JournalProvider: Delete successful. Old list length: $oldLength, New list length: ${journalList.length}');
    } else {
      debugPrint('JournalProvider: Delete failed. Error: ${error?.title ?? "Unknown error"}');
    }

    addingJournal = false;
    addingHomeJournal = false;
    notifyListeners();
    return data;
  }
}
