import 'package:flutter/material.dart';

import '../application/model/question_model.dart';
import '../application/repo/question_repo.dart';

class QuestionProvider extends ChangeNotifier {
  QuestionProvider() {
    init();
  }

  QuestionPaginator? _questionPaginator;
  List<Question> questionList = [];

  bool isLoading = false;
  bool isPaginating = false;
  bool reachEnd = false;

  /// The category ID currently being used to filter questions.
  /// null means no category filter (general questions).
  String? selectedCategoryId;

  final QuestionRepo _questionRepo = QuestionRepo();

  init() async {
    getQuestion();
  }

  /// Reset and reload questions without any category filter.
  Future<void> resetPaginator() async {
    selectedCategoryId = null;
    _questionPaginator = null;
    questionList = [];
    reachEnd = false;
    notifyListeners();
    await getQuestion();
  }

  /// Reset and reload questions filtered by [categoryId].
  /// Pass null to clear the category filter and load general questions.
  Future<void> resetWithCategory(String? categoryId) async {
    selectedCategoryId = categoryId;
    _questionPaginator = null;
    questionList = [];
    reachEnd = false;
    notifyListeners();
    await getQuestion();
  }

  Future<void> ensureMinimumQuestions(int minCount) async {
    while (questionList.length < minCount && !reachEnd) {
      final previousLength = questionList.length;
      await getQuestion();
      if (questionList.length <= previousLength) {
        break;
      }
    }
  }

  Future<void> getQuestion() async {
    if (_questionPaginator == null) {
      isLoading = true;
    } else {
      isPaginating = true;
    }
    if (_questionPaginator != null && _questionPaginator?.pageToken == null) {
      reachEnd = true;
      isLoading = false;
      isPaginating = false;
      notifyListeners();
      return;
    }
    notifyListeners();

    final catId = selectedCategoryId;

    if (catId != null && catId.isNotEmpty) {
      // Fetch questions filtered by the selected category
      final (data, error) = await _questionRepo.getSegmentedQuestions(
        categoryId: catId,
        pageToken: _questionPaginator?.pageToken,
      );

      if (data != null) {
        _questionPaginator = data;
        questionList.addAll(data.data);
      }

      debugPrint(
        'QuestionProvider: Loaded ${questionList.length} questions for category $catId. Error: $error',
      );
    } else {
      // No category selected — load general questions
      final (data, error) = await _questionRepo.getQuestionSet(
        pageToken: _questionPaginator?.pageToken,
      );

      if (data != null) {
        _questionPaginator = data;
        questionList.addAll(data.data);
      }

      debugPrint(
        'QuestionProvider: Loaded ${questionList.length} general questions. Error: $error',
      );
    }

    isLoading = false;
    isPaginating = false;
    notifyListeners();
  }
}
