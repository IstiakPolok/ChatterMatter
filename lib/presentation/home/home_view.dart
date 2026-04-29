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

import '../../common/custom_question_tile.dart';
import '../../providers/question_provider.dart';
import '../notification/notification_view.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_){
      syncSubscription();
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

    debugPrint("ALL ENTITLEMENTS: ${info.entitlements.all}");
    debugPrint("ACTIVE ENTITLEMENTS: ${info.entitlements.active}");

    if (info.entitlements.all['vip_plans']?.isActive == true) {
      userBloc.updatesubscription(SubscriptionType.vip);
      await questionProvider.ensureMinimumQuestions(20);

    } else if (info.entitlements.all['standard_plans']?.isActive == true) {
      userBloc.updatesubscription(SubscriptionType.standard);
      await questionProvider.ensureMinimumQuestions(10);

    } else {
      userBloc.updatesubscription(SubscriptionType.free);
      if (questionProvider.questionList.length < 2) {
        await questionProvider.ensureMinimumQuestions(2);
      }
    }

  } catch (e) {
    debugPrint("Sync error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    final QuestionProvider questionProvider = context.watch();
    final UserBloc userBloc = context.watch();
    final favList = userBloc.profile?.favoriteQuestionIds ?? [];
    final profile = userBloc.profile;

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
                      Text("Good morning",
                          style: bodyMedium(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Text(profile?.name ?? "",
                              style: titleLarge(color: customBlack)),
                          Image.asset("assets/icons/hi.png"),
                        ],
                      ),
                      const SizedBox(height: 6),
                 
                    ],
                  ),
                ),

                InkWell(
                  onTap: () =>
                      animatedNavigateTo(context, NotificationView()),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.notifications,
                        color: customLightPurple),
                  ),
                ),
              ],
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
                            if (profile?.subscriptionType.name == SubscriptionType.vip.name) {
                              return length.toString();
                            } else if (profile?.subscriptionType.name == SubscriptionType.standard.name) {
                              return (length > 10 ? 10 : length).toString();
                            } else {
                              return (length > 1 ? 1 : length).toString();
                            }
                          })(),
                          style: bodyLarge(color: customLightPurple),
                        ),
                        Text((() {
                          final length = questionProvider.questionList.length;
                          if (profile?.subscriptionType.name == SubscriptionType.vip.name) {
                            return "/ $length";
                          } else if (profile?.subscriptionType.name == SubscriptionType.standard.name) {
                            return "/ 10";
                          } else {
                            return "/ 1";
                          }
                        })()),
                      ],
                    ),
                  ),
              ],
            ),
            vPad20,


            /// VIP CARD
           
if (profile?.subscriptionType.name !=SubscriptionType.vip.name)
              Card(
                color: customWhite,
                elevation: 2,
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SubscriptionView1()),
                  ),
                  title: Text(
                    profile?.subscriptionType.name ==SubscriptionType.standard.name ? "Upgrade to VIP" : "Unlock VIP Access",
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
              child: questionProvider.isLoading
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
                                  onPressed: () => questionProvider.resetPaginator(),
                                  child: Text("Retry"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : CarouselSlider(
                          items: (() {
                            List<Question> questionsToShow;

                            if (profile?.subscriptionType.name ==
                                SubscriptionType.vip.name) {
                              questionsToShow =
                                  questionProvider.questionList;
                            } else if (profile?.subscriptionType.name ==
                                SubscriptionType.standard.name) {
                              questionsToShow = questionProvider
                                  .questionList
                                  .take(10)
                                  .toList();
                            } else {
                              questionsToShow = questionProvider
                                  .questionList
                                  .take(1)
                                  .toList();
                            }

                            return List.generate(
                              questionsToShow.length,
                              (i) => CustomQuestionTile(
                                index: i,
                                question: questionsToShow[i],
                                isFavorite: favList.contains(
                                  questionsToShow[i].id,
                                ),
                                onTapFav: () async => userBloc.addFavQuestion(
                                  questionsToShow[i].id,
                                ),
                              ),
                            );
                          })(),
                          options: CarouselOptions(
                            height: 350,
                            viewportFraction: 1,
                            enlargeCenterPage: true,
                            onPageChanged: (ind, e) {
                              if (profile?.subscriptionType.name ==
                                      SubscriptionType.vip.name &&
                                  questionProvider.questionList.length - 2 <
                                      ind) {
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
            if (profile?.subscriptionType.name ==
                SubscriptionType.free.name)
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
          Text(widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

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



