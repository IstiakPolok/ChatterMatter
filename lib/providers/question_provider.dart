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

  final QuestionRepo _questionRepo = QuestionRepo();

  init() async {
    getQuestion();
  }

  Future<void> resetPaginator() async {
    _questionPaginator = null;
    questionList = [];
    notifyListeners();
    await getQuestion();
  }

  Future<void> ensureMinimumQuestions(int minCount) async {
    while (questionList.length < minCount && !reachEnd) {
      await getQuestion();
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

    final (data, error) = await _questionRepo.getQuestionSet(
      pageToken: _questionPaginator?.pageToken,
    );

    if (data != null) {
      _questionPaginator = data;
      questionList.addAll(data.data);
    }

    isLoading = false;
    isPaginating = false;
    notifyListeners();
  }
}
