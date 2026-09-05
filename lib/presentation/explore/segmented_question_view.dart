import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../application/model/category_model.dart';
import '../../application/model/question_model.dart';
import '../../application/repo/question_repo.dart';
import '../../common/colors.dart';
import '../../common/custom_buttons.dart';
import '../../common/custom_question_tile.dart';
import '../../common/custom_text_style.dart';
import '../../common/gradiant_background.dart';
import '../../common/padding.dart';
import 'explore_view.dart';

class SegmentedQuestionView extends StatefulWidget {
  const SegmentedQuestionView({super.key, required this.category});
  final Category category;
  @override
  State<SegmentedQuestionView> createState() => _SegmentedQuestionViewState();
}

class _SegmentedQuestionViewState extends State<SegmentedQuestionView> {
  QuestionPaginator? _questionPaginator;
  List<Question> questionList = [];

  bool isLoading = false;
  bool isPaginating = false;
  bool reachEnd = false;
  bool _isFetching = false;

  final QuestionRepo _questionRepo = QuestionRepo();

  CategoryTileConfig? config;

  init() async {
    getQuestion();
  }

  void resetPaginator() async {
    _questionPaginator = null;
    questionList = [];
    getQuestion();
  }

  void getQuestion() async {
    debugPrint(
      'SegmentedQuestionView: getQuestion() requested for category: "${widget.category.title}" (ID: ${widget.category.id})',
    );
    if (_isFetching) return;

    if (_questionPaginator == null) {
      isLoading = true;
    } else {
      isPaginating = true;
    }
    _isFetching = true;
    if (_questionPaginator != null && _questionPaginator?.pageToken == null) {
      debugPrint(
        'SegmentedQuestionView: Reached the end of paginated questions (next pageToken is null).',
      );
      reachEnd = true;
      return;
    }
    setState(() {});

    debugPrint(
      'SegmentedQuestionView: Calling getQuestionsByCategory API with categoryId: "${widget.category.id}" and pageToken: "${_questionPaginator?.pageToken}"',
    );
    final (data, error) = await _questionRepo.getQuestionsByCategory(
      categoryId: widget.category.id,
      pageToken: _questionPaginator?.pageToken,
    );

    if (data != null) {
      // If it's a fresh fetch (first page), ensure the list is clean
      if (_questionPaginator == null) {
        questionList = [];
        debugPrint(
          'SegmentedQuestionView: Fresh fetch, cleared existing question list.',
        );
      }

      _questionPaginator = data;
      questionList.addAll(data.data);

      debugPrint(
        'SegmentedQuestionView: API Response Data: ${data.data.map((q) => q.title).toList()}',
      );
      debugPrint(
        'SegmentedQuestionView: Successfully loaded ${data.data.length} questions. Total in list: ${questionList.length}. Next pageToken: "${data.pageToken}"',
      );
    } else {
      debugPrint(
        'SegmentedQuestionView: Failed to load questions. Error: ${error?.title ?? "Unknown error"}',
      );
    }

    isLoading = false;
    isPaginating = false;
    _isFetching = false;
    setState(() {});
  }

  @override
  void initState() {
    getQuestion();
    config = categoryTileConfigs[widget.category.colorPalette]!;
    super.initState();
  }

  int currentQuestion = 1;

  onPageChange(int index) {
    setState(() {
      currentQuestion = index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: customGradientBackgroundWithSvg(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  primaryBackButton(context: context),
                  Column(
                    children: [
                      Text(widget.category.title, style: heading()),
                      Text(
                        widget.category.subTitle,
                        style: bodyMedium(color: customDarkGray),
                      ),
                    ],
                  ),

                  hPad30,
                ],
              ),
            ),

            vPad20,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Question"),
                Text(" $currentQuestion of "),
                Text("${questionList.length}"),
                hPad15,
              ],
            ),
            vPad10,
            // Show a single tile when only one question, otherwise a carousel
            questionList.isEmpty
                ? const SizedBox()
                : questionList.length == 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 350,
                          child: CustomQuestionTile(
                            isFavorite: true,
                            onTapFav: () {},
                            index: 0,
                            question: questionList[0],
                            bg: config!.backgroundColor,
                            bgImage: config!.backgroundImage,
                          ),
                        ),
                      )
                    : CarouselSlider(
                        items: List.generate(
                          questionList.length,
                          (i) => CustomQuestionTile(
                            isFavorite: true,
                            onTapFav: () {},
                            index: i,
                            question: questionList[i],
                            bg: config!.backgroundColor,
                            bgImage: config!.backgroundImage,
                          ),
                        ),
                        options: CarouselOptions(
                          aspectRatio: 1,
                          height: 400,
                          viewportFraction: .95,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            onPageChange(index);
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
