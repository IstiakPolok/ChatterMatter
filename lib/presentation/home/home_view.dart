import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatter_matter_app/application/model/question_model.dart';
import 'package:chatter_matter_app/application/user/auth_bloc.dart';
import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:intl/intl.dart';
import 'package:chatter_matter_app/common/navigator.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/common/see_%20loading.dart';
import 'package:chatter_matter_app/core/enums.dart';

import 'package:chatter_matter_app/presentation/subsription/inapsubs.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../application/adds/add.dart';

import 'package:chatter_matter_app/application/model/category_model.dart'
    as category_model;
import 'package:chatter_matter_app/providers/dashboard_provider.dart';
import '../../common/custom_question_tile.dart';
import '../../providers/question_provider.dart';
import '../notification/notification_view.dart';
import '../setting/showcase_keys.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncSubscription();

      // Fetch fresh data from the API every time HomeView opens
      final userBloc = context.read<UserBloc>();
      final qProvider = context.read<QuestionProvider>();
      final selectedCats = userBloc.profile?.selectedCategories ?? [];

      // Only load questions if a category is selected.
      // If no category is selected, show "Please select a category" message.
      if (selectedCats.isNotEmpty) {
        qProvider.resetWithCategories(selectedCats);
      }
    });
  }

  void call() async {
    await myBanner.load();
  }

  /// ✅ NEW: Sync subscription from RevenueCat
  Future<void> syncSubscription() async {
    try {
      final info = await Purchases.getCustomerInfo();

      final userBloc = context.read<UserBloc>();
      final questionProvider = context.read<QuestionProvider>();

      debugPrint(
        "REVENUECAT ALL ENTITLEMENTS: ${info.entitlements.all.keys.toList()}",
      );
      debugPrint(
        "REVENUECAT ACTIVE ENTITLEMENTS: ${info.entitlements.active.keys.toList()}",
      );

      final isVipActive = info.entitlements.all['vip_plans']?.isActive == true;
      final isStandardActive =
          info.entitlements.all['standard_plans']?.isActive == true;

      if (isVipActive) {
        userBloc.updatesubscription(SubscriptionType.vip);
      } else if (isStandardActive) {
        // Prevent downgrading to standard if the profile already shows VIP
        if (userBloc.profile?.subscriptionType != SubscriptionType.vip) {
          userBloc.updatesubscription(SubscriptionType.standard);
        } else {
          debugPrint(
            "Sync: User is already VIP in profile, skipping downgrade to Standard.",
          );
        }
      } else {
        userBloc.updatesubscription(SubscriptionType.free);
      }
    } catch (e) {
      debugPrint("Sync error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestionProvider questionProvider = context.watch();
    final UserBloc userBloc = context.watch();
    final DashboardProvider dashboardProvider = context.watch();
    final profile = userBloc.profile;
    final favList = profile?.favoriteQuestionIds ?? [];
    final selectedCategories = profile?.selectedCategories ?? [];
    final categoryList = dashboardProvider.categoryList;
    final showSelectCategoryPrompt = selectedCategories.isEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        await questionProvider.resetPaginator();
        await syncSubscription(); // ✅ refresh on pull
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            /// HEADER
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good morning",
                        style: bodyMedium(fontWeight: FontWeight.w500),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            profile?.name ?? "",
                            style: titleLarge(color: customBlack),
                          ),
                          Image.asset("assets/icons/hi.png", height: 24),
                          _buildSubscriptionBadge(profile?.subscriptionType),
                        ],
                      ),
                      if (profile?.subscriptionType == SubscriptionType.free)
                        GestureDetector(
                          onTap: () => animatedNavigateTo(
                            context,
                            const SubscriptionView1(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Upgrade to unlock all features",
                              style: bodySmall(
                                color: customLightPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                InkWell(
                  onTap: () => animatedNavigateTo(context, NotificationView()),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: customLightPurple,
                    ),
                  ),
                ),
              ],
            ),

            vPad20,

            /// QUICK CATEGORY SELECTOR
            Showcase(
              key: ShowcaseKeys.categoriesKey,
              title: "🗂️ Step 4 — Explore Categories",
              description:
                  "Browse the 10 categories. Pick one that feels right and tap to see your question.",
              tooltipBackgroundColor: const Color(0xFF8B6BBD),
              textColor: Colors.white,
              titleTextStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              descTextStyle: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              child: _buildQuickCategorySelector(
                categoryList,
                selectedCategories,
              ),
            ),

            vPad20,

            /// QUESTION OF THE DAY
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/icons/star.png"),
                          SizedBox(width: 5),
                          Text("Question of the Day", style: titleSmall()),
                        ],
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                        style: bodyMedium(color: customDarkGray),
                      ),
                    ],
                  ),
                ),
                if (profile?.subscriptionType.name != SubscriptionType.vip.name)
                  Container(
                    height: 35,
                    width: 50,
                    decoration: BoxDecoration(
                      color: customWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: customLightGray),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (() {
                            final length = questionProvider.questionList.length;
                            if (profile?.subscriptionType.name ==
                                SubscriptionType.vip.name) {
                              return length.toString();
                            } else if (profile?.subscriptionType.name ==
                                SubscriptionType.standard.name) {
                              return (length > 10 ? 10 : length).toString();
                            } else {
                              return (length > 1 ? 1 : length).toString();
                            }
                          })(),
                          style: bodyLarge(color: customLightPurple),
                        ),
                        Text(
                          (() {
                            final length = questionProvider.questionList.length;
                            if (profile?.subscriptionType.name ==
                                SubscriptionType.vip.name) {
                              return "/ $length";
                            } else if (profile?.subscriptionType.name ==
                                SubscriptionType.standard.name) {
                              return "/ 10";
                            } else {
                              return "/ 1";
                            }
                          })(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            vPad20,

            /// VIP CARD
            if (profile?.subscriptionType.name != SubscriptionType.vip.name)
              Card(
                color: customWhite,
                elevation: 2,
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SubscriptionView1()),
                  ),
                  title: Text(
                    profile?.subscriptionType.name ==
                            SubscriptionType.standard.name
                        ? "Upgrade to VIP"
                        : "Unlock VIP Access",
                  ),
                  subtitle: Text("Unlimited questions • No ads"),
                  leading: Image.asset("assets/icons/vip.png"),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: customLightPurple,
                    ),
                    child: Text(
                      "Upgrade",
                      style: titleSmall(color: customWhite),
                    ),
                  ),
                ),
              ),

            vPad20,

            /// SLIDER
            SizedBox(
              child: showSelectCategoryPrompt
                  ? SizedBox(
                      height: 350,
                      child: Center(
                        child: Text(
                          "Please select a category.",
                          style: bodyMedium(
                            color: customLightPurple,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : questionProvider.isLoading
                  ? SizedBox(height: 350, child: cLoading())
                  : questionProvider.questionList.isEmpty
                  ? SizedBox(
                      height: 350,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No questions available at the moment. Please try again later.",
                              style: bodyMedium(),
                              textAlign: TextAlign.center,
                            ),
                            vPad20,
                            ElevatedButton(
                              onPressed: () =>
                                  questionProvider.resetPaginator(),
                              child: Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : questionProvider.questionList.length == 1
                  ? SizedBox(
                      height: 350,
                      child: CustomQuestionTile(
                        index: 0,
                        question: questionProvider.questionList[0],
                        isFavorite: favList.contains(
                          questionProvider.questionList[0].id,
                        ),
                        onTapFav: () async => userBloc.addFavQuestion(
                          questionProvider.questionList[0].id,
                        ),
                      ),
                    )
                  : CarouselSlider(
                      items: (() {
                        final questionsToShow = questionProvider.questionList;

                        return List.generate(
                          questionsToShow.length,
                          (i) => CustomQuestionTile(
                            index: i,
                            question: questionsToShow[i],
                            isFavorite: favList.contains(questionsToShow[i].id),
                            onTapFav: () async =>
                                userBloc.addFavQuestion(questionsToShow[i].id),
                          ),
                        );
                      })(),
                      options: CarouselOptions(
                        height: 350,
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        onPageChanged: (ind, e) {
                          final isVip =
                              profile?.subscriptionType.name ==
                              SubscriptionType.vip.name;
                          final isCategorySelected =
                              selectedCategories.isNotEmpty;

                          // For category-selected flows, keep the first 10 questions
                          // and do not auto-load the next page immediately.
                          if (isVip &&
                              !isCategorySelected &&
                              questionProvider.questionList.length - 2 < ind) {
                            questionProvider.getQuestion();
                          }
                        },
                      ),
                    ),
            ),

            vPad20,

            /// STATUS BOX
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.all(defaultPadding),
            //   decoration: BoxDecoration(
            //     borderRadius:
            //         BorderRadius.circular(defaultRadius),
            //     color: customLightYellow,
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(
            //         profile?.subscriptionType.name ==
            //                 SubscriptionType.vip.name
            //             ? Icons.check_circle_outline
            //             : Icons.error_outline,
            //       ),
            //       SizedBox(width: 8),
            //       Expanded(
            //         child: Text(
            //           profile?.subscriptionType.name ==
            //                   SubscriptionType.vip.name
            //               ? "You're enjoying VIP"
            //               : "Daily limit reached. Upgrade!",
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            vPad20,

            /// ADS
            if (profile?.subscriptionType.name == SubscriptionType.free.name)
              Container(
                alignment: Alignment.center,
                width: myBanner.size.width.toDouble(),
                height: myBanner.size.height.toDouble(),
                child: AdWidget(ad: myBanner),
              ),

            vPad35,
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCategorySelector(
    List<category_model.Category> categories,
    List<String> selectedIds,
  ) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text("Categories", style: titleSmall()),
        ),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedIds.contains(category.id);
              return _buildCategoryChip(
                title: category.title,
                isSelected: isSelected,
                onTap: () {
                  debugPrint(
                    'Category tapped: ${category.title} (id=${category.id})',
                  );
                  _handleCategoryToggle(category.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? customLightPurple : customWhite,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? customLightPurple : customLightGray,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: customLightPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: bodyMedium(
              color: isSelected ? customWhite : customDarkGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _handleCategoryToggle(String categoryId) async {
    final userBloc = context.read<UserBloc>();
    final qProvider = context.read<QuestionProvider>();

    debugPrint('\n=== CATEGORY CLICKED ===');
    debugPrint('Category ID: $categoryId');

    if (categoryId.isEmpty) {
      // "All" selected: Clear categories in AuthBloc and reset questions
      debugPrint('Clearing all categories');
      userBloc.clearSelectedCategories();
      await qProvider.resetPaginator();
      debugPrint('=== END CATEGORY TOGGLE ===\n');
      return;
    }

    // Toggle via AuthBloc logic (Optimistic/Parallel)
    userBloc.updateSelectedCategory(categoryId);
    debugPrint('Updated selected category in UserBloc');

    // Refresh questions immediately
    final updatedSelected = userBloc.profile?.selectedCategories ?? [];
    debugPrint('Current selected categories: $updatedSelected');
    if (updatedSelected.isNotEmpty) {
      debugPrint('Fetching questions for categories: $updatedSelected');
      await qProvider.resetWithCategories(updatedSelected);
    } else {
      debugPrint('No categories selected, fetching general questions');
      await qProvider.resetPaginator();
    }
    debugPrint(
      'Questions loaded. Total count: ${qProvider.questionList.length}',
    );
    debugPrint('=== END CATEGORY TOGGLE ===\n');
  }

  Widget _buildSubscriptionBadge(SubscriptionType? type) {
    Color bgColor;
    Color textColor;
    String label;
    IconData? icon;

    switch (type) {
      case SubscriptionType.vip:
        bgColor = customDarkPurple;
        textColor = Colors.white;
        label = "VIP";
        icon = Icons.stars_rounded;
        break;
      case SubscriptionType.standard:
        bgColor = customLightPurple.withOpacity(0.2);
        textColor = customDarkPurple;
        label = "Standard";
        icon = Icons.verified_user_rounded;
        break;
      case SubscriptionType.free:
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = "Free";
        icon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: type == SubscriptionType.vip
            ? Border.all(color: Colors.amber.shade300, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: type == SubscriptionType.vip
                  ? Colors.amber.shade300
                  : textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// utils ....
class Utils {
  static void showSheet(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }
}

// purchase api ....
class PurchasesApi {
  static const _apikey = 'appl_JBhiRCOzUslyWXGrYYJrvXtNWzq';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(_apikey);
  }

  /// ✅ NEW: Get ALL packages from all offerings
  static Future<List<Package>> getAllPackages() async {
    try {
      final offerings = await Purchases.getOfferings();

      final allPackages = <Package>[];

      for (final offering in offerings.all.values) {
        allPackages.addAll(offering.availablePackages);
      }

      return allPackages;
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      return [];
    }
  }
}

// paywall widget....
class PaywallWidget extends StatefulWidget {
  final List<Package> packages;
  final String title;
  final String description;
  final Future<void> Function(Package package) onClickedPackage;

  const PaywallWidget({
    super.key,
    required this.packages,
    required this.title,
    required this.description,
    required this.onClickedPackage,
  });

  @override
  State<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> {
  Package? selectedPackage;

  @override
  void initState() {
    super.initState();
    if (widget.packages.isNotEmpty) {
      selectedPackage = widget.packages.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Description
          Text(widget.description, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          // Packages list
          ...widget.packages.map((pkg) {
            final isSelected = pkg == selectedPackage;

            return GestureDetector(
              onTap: () => setState(() => selectedPackage = pkg),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pkg.storeProduct.title),
                    Text(pkg.storeProduct.priceString),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          // Subscribe Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedPackage == null
                  ? null
                  : () => widget.onClickedPackage(selectedPackage!),
              child: const Text("Subscribe"),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
