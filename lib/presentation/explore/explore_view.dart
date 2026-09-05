import 'package:chatter_matter_app/application/model/category_model.dart';
import 'package:chatter_matter_app/application/user/auth_bloc.dart';
import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/common/snack_bar.dart';
import 'package:chatter_matter_app/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
part 'custom_tile.dart';
part 'components/custom_tile.dart';
part 'components/custom_style.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  bool isLoading = false;
  void updateCategory({
    // required SubscriptionType subType,
    required String categoryId,
  }) async {
    setState(() {
      isLoading = true;
    });

    final (check, error) = await Provider.of<UserBloc>(
      context,
      listen: false,
    ).updateSelectedCategory(categoryId);

    if (check != null && mounted) {
      final selectedCats =
          Provider.of<UserBloc>(
            context,
            listen: false,
          ).profile?.selectedCategories ??
          [];
      Provider.of<QuestionProvider>(
        context,
        listen: false,
      ).resetWithCategories(selectedCats);
    }
    if (!mounted) return;
    if (mounted && check != null && context.mounted) {
      showToast(context: context, title: check, toastType: ToastType.success);
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

  @override
  Widget build(BuildContext context) {
    final DashboardProvider dashboardProvider = context.watch();
    final category = dashboardProvider.categoryList;

    final UserBloc userBloc = context.watch();
    final selectedCategory = userBloc.profile?.selectedCategories ?? [];
    print(selectedCategory);
    return Column(
      children: [
        Text("Explore", style: heading()),
        Text(
          "Select the category You want to see questions",
          style: bodyMedium(color: customDarkGray),
        ),
        vPad10,
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => dashboardProvider.getCategoryList(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding),

              child: dashboardProvider.isFetchingCategory
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      spacing: 15,
                      children: [
                        if (category.isEmpty)
                          Column(
                            children: [
                              vPad35,
                              Text("No Data found."),

                              IconButton(
                                onPressed: () {
                                  dashboardProvider.getCategoryList();
                                },
                                icon: Icon(Icons.refresh),
                              ),
                            ],
                          ),

                        ...List.generate(
                          category.length,
                          (index) => InkWell(
                            onTap: isLoading
                                ? null
                                : () => updateCategory(
                                    categoryId: category[index].id,
                                  ),
                            child: customTile(
                              category: category[index],
                              isSelected: selectedCategory.contains(
                                category[index].id,
                              ),
                            ),
                          ),
                        ),

                        // vPad20,
                        // customTile(CategoryTileType.reflectingOnTheDay),
                        // customTile(CategoryTileType.fosteringOpenness),
                        // customTile(CategoryTileType.strengtheningTrust),
                        // customTile(CategoryTileType.exploringEmotions),
                        // customTile(CategoryTileType.encouragingGrowth),
                        // customTile(CategoryTileType.buildingFamilyConnections),
                        // customTile(CategoryTileType.imaginativeFunQuestions),
                        // customTile(CategoryTileType.celebratingAccomplishments),
                        // customTile(CategoryTileType.deepeningUnderstanding),
                        // customTile(CategoryTileType.selfWorthAndLove),
                        vPad35,
                        // customTile(CategoryTileType.selfWorthAndLove),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
