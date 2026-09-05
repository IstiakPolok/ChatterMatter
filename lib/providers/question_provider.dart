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

  /// The category IDs currently being used to filter questions.
  /// Empty list means no category filter (general questions).
  List<String> selectedCategoryIds = [];

  final QuestionRepo _questionRepo = QuestionRepo();

  init() async {
    // Do not auto-load questions on init.
    // Let HomeView decide whether to load based on selected categories.
  }

  /// Reset and reload questions without any category filter.
  Future<void> resetPaginator() async {
    selectedCategoryIds = [];
    _questionPaginator = null;
    questionList = [];
    reachEnd = false;
    notifyListeners();
    await getQuestion();
  }

  /// Reset and reload questions filtered by [categoryIds].
  /// Pass an empty list to clear the category filter and load general questions.
  Future<void> resetWithCategories(List<String> categoryIds) async {
    selectedCategoryIds = categoryIds;
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
    if (isLoading || isPaginating) return;

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

    final catIds = selectedCategoryIds;

    if (catIds.isNotEmpty) {
      debugPrint(
        'QuestionProvider: Fetching questions for category IDs: $catIds',
      );
      final (data, error) = await _questionRepo.getQuestionsByCategory(
        categoryId: catIds.join(','),
        pageToken: _questionPaginator?.pageToken,
      );

      if (data != null) {
        final isFreshFetch = _questionPaginator == null;
        _questionPaginator = data;

        if (isFreshFetch) {
          questionList = [];
          debugPrint(
            'QuestionProvider: Fresh fetch, cleared existing question list.',
          );
        }
        questionList.addAll(data.data);

        debugPrint('\n📊 API RESPONSE for Categories: $catIds');
        debugPrint('📊 Total questions in response: ${data.data.length}');
        debugPrint(
          '📊 Question titles: ${data.data.map((q) => q.title).toList()}',
        );
        debugPrint('📊 Question IDs: ${data.data.map((q) => q.id).toList()}');
        debugPrint('📊 Total questions loaded so far: ${questionList.length}');
        debugPrint('📊 Next page token: ${data.pageToken}\n');
      }

      debugPrint(
        'QuestionProvider: Successfully loaded ${data?.data.length ?? 0} questions for categories $catIds. Total: ${questionList.length}. Error: $error',
      );
    } else {
      debugPrint(
        'QuestionProvider: Fetching general questions (no categories selected).',
      );
      final (data, error) = await _questionRepo.getQuestionSet(
        pageToken: _questionPaginator?.pageToken,
      );

      if (data != null) {
        final isFreshFetch = _questionPaginator == null;
        _questionPaginator = data;

        if (isFreshFetch) {
          questionList = [];
          debugPrint(
            'QuestionProvider: Fresh fetch, cleared existing question list.',
          );
        }
        questionList.addAll(data.data);

        debugPrint('\n📊 API RESPONSE (General Questions)');
        debugPrint('📊 Total questions in response: ${data.data.length}');
        debugPrint(
          '📊 Question titles: ${data.data.map((q) => q.title).toList()}',
        );
        debugPrint('📊 Question IDs: ${data.data.map((q) => q.id).toList()}');
        debugPrint('📊 Total questions loaded so far: ${questionList.length}');
        debugPrint('📊 Next page token: ${data.pageToken}\n');
      }

      debugPrint(
        'QuestionProvider: Successfully loaded ${data?.data.length ?? 0} general questions. Total: ${questionList.length}. Error: $error',
      );
    }

    isLoading = false;
    isPaginating = false;
    notifyListeners();
  }
}
