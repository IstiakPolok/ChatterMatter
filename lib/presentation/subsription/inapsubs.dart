import 'dart:io';
import 'package:chatter_matter_app/application/user/auth_bloc.dart';
import 'package:chatter_matter_app/application/repo/subscription_repo.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/core/enums.dart';
import 'package:chatter_matter_app/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:chatter_matter_app/common/colors.dart';

class SubscriptionView1 extends StatefulWidget {
  const SubscriptionView1({super.key});

  @override
  State<SubscriptionView1> createState() => _SubscriptionView1State();
}

class _SubscriptionView1State extends State<SubscriptionView1> {
  List<Package> standardPackages = [];
  List<Package> vipPackages = [];

  Package? selectedPackage;
  bool isLoading = false;
  bool isAgreed = false;
  final TextEditingController couponController = TextEditingController();
  bool isApplyingCoupon = false;

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  Future<void> _openUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);

    try {
      if (kIsWeb) {
        final launched = await launchUrl(url, webOnlyWindowName: '_blank');
        if (!launched) {
          debugPrint('Failed to launch URL on web: $url');
        }
      } else {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          debugPrint('Failed to launch URL on device: $url');
        }
      }
    } catch (e) {
      debugPrint('Open URL error: $e');
    }
  }

  /// 🔥 FETCH + GROUP PACKAGES
  Future<void> loadPackages() async {
    try {
      final offerings = await Purchases.getOfferings();

      final List<Package> standard = [];
      final List<Package> vip = [];

      for (final offering in offerings.all.values) {
        for (final pkg in offering.availablePackages) {
          final id = pkg.storeProduct.identifier;

          if (id.contains("standard")) {
            standard.add(pkg);
          } else if (id.contains("vip")) {
            vip.add(pkg);
          }
        }
      }

      setState(() {
        standardPackages = standard;
        vipPackages = vip;

        if (standard.isNotEmpty) {
          selectedPackage = standard.first;
        }
      });
    } catch (e) {
      debugPrint("Error loading packages: $e");
    }
  }

  /// 🔥 PURCHASE
  Future<void> purchasePackage() async {
    if (selectedPackage == null) return;

    try {
      setState(() => isLoading = true);

      final result = await Purchases.purchasePackage(selectedPackage!);

      final userBloc = context.read<UserBloc>();
      final questionProvider = context.read<QuestionProvider>();

      final entitlements = result.customerInfo.entitlements;

      debugPrint("PURCHASE ENTITLEMENTS: ${entitlements.all}");

      final identifier = selectedPackage!.storeProduct.identifier.toLowerCase();
      String subTypeStr = 'free';

      if (entitlements.all['vip_plans']?.isActive == true ||
          identifier.contains('vip')) {
        debugPrint("VIP UNLOCKED");
        userBloc.updatesubscription(SubscriptionType.vip);
        subTypeStr = 'vip';
      } else if (entitlements.all['standard_plans']?.isActive == true ||
          identifier.contains('standard')) {
        debugPrint("STANDARD UNLOCKED");
        userBloc.updatesubscription(SubscriptionType.standard);
        subTypeStr = 'standard';
      } else {
        userBloc.updatesubscription(SubscriptionType.free);
        subTypeStr = 'free';
      }

      try {
        final subRepo = SubscriptionRepo();
        final durationType = selectedPackage!.packageType == PackageType.monthly
            ? "monthly"
            : "yearly";
        final transactionId = "rc_${result.customerInfo.originalAppUserId}";

        String subscriptionId;
        if (subTypeStr == 'vip') {
          subscriptionId = 'jE4ZzyOiYr5nOcbNgtn2';
        } else if (subTypeStr == 'standard') {
          subscriptionId = 'Tqwms4mpcskNYA1IogtV';
        } else {
          subscriptionId = 'ROjDdZqRU3dtqRPZeVK0';
        }

        await subRepo.updateSubscriptionInBackend(
          subscriptionId: subscriptionId,
          planDurationType: durationType,
          price: selectedPackage!.storeProduct.price,
          transactionId: transactionId,
        );

        // 🔥 NEW: Log detailed transaction data
        await subRepo.addTransaction(
          plan: selectedPackage!.storeProduct.title,
          cost: selectedPackage!.storeProduct.price,
          time: DateTime.now().toIso8601String(),
          store: Platform.isIOS ? "App Store" : "Play Store",
          currency: selectedPackage!.storeProduct.currencyCode,
          transactionId: transactionId,
        );
        debugPrint("✅ Logged transaction to /addTransaction");
        debugPrint("✅ Sent updateSubscription to backend for $subTypeStr");
      } catch (e) {
        debugPrint("❌ Error sending subscription to backend: $e");
      }

      await userBloc.fetchProfile(); // Ensure profile is updated from server
      await questionProvider.resetPaginator();

      // if (entitlements.all['vip_plans']?.isActive == true) {
      //   await questionProvider.ensureMinimumQuestions(20);
      // } else if (entitlements.all['standard_plans']?.isActive == true) {
      //   await questionProvider.ensureMinimumQuestions(10);
      // }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Purchase successful 🎉")));

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Purchase error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔥 BUILD SECTION UI
  Widget buildSection(String title, List<Package> packages) {
    final List<String> features = title == "VIP"
        ? ["Unlimited Access", "Premium Features", "Priority Support", "No Ads"]
        : ["Limited Access", "Basic Features", "Ads Included"];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: title == "VIP"
            ? Colors.purple.withOpacity(0.05)
            : Colors.green.withOpacity(0.05),
        border: Border.all(
          color: title == "VIP" ? Colors.purple : Colors.green,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 TITLE
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: title == "VIP" ? Colors.purple : Colors.green,
            ),
          ),

          const SizedBox(height: 12),

          /// 🔥 FEATURES
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 18, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(f),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          /// 🔥 MONTHLY / YEARLY OPTIONS
          ...packages.map((pkg) {
            final isSelected = selectedPackage == pkg;
            final isMonthly = pkg.packageType == PackageType.monthly;

            final label = isMonthly ? "Monthly" : "Yearly";

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPackage = pkg;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(label),

                        /// 🔥 BEST VALUE TAG
                        if (!isMonthly)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "BEST",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(pkg.storeProduct.priceString),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = context.watch<UserBloc>();
    final isVip = userBloc.profile?.subscriptionType.name == "vip";
    final isStandard = userBloc.profile?.subscriptionType.name == "standard";

    final isEmpty = standardPackages.isEmpty && vipPackages.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Plan Purchase"), centerTitle: true),
      body: isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 🔥 SCROLL CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (isVip) ...[
                          const SizedBox(height: 40),
                          const Icon(Icons.star, color: Colors.purple, size: 80),
                          const SizedBox(height: 20),
                          const Text("You are on the VIP Plan!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
                          const SizedBox(height: 10),
                          const Text("All premium features are unlocked.", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red),
                              onPressed: () {
                                try {
                                  if (Platform.isIOS) {
                                    _openUrl('https://apps.apple.com/account/subscriptions');
                                  } else {
                                    _openUrl('https://play.google.com/store/account/subscriptions');
                                  }
                                } catch (e) {
                                  debugPrint("Manage subscriptions error: $e");
                                }
                              },
                              child: const Text("Cancel Subscription", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ] else if (isStandard) ...[
                          if (vipPackages.isNotEmpty) ...[
                            const Text("Ready for more?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            buildSection("VIP", vipPackages),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red),
                              onPressed: () {
                                try {
                                  if (Platform.isIOS) {
                                    _openUrl('https://apps.apple.com/account/subscriptions');
                                  } else {
                                    _openUrl('https://play.google.com/store/account/subscriptions');
                                  }
                                } catch (e) {
                                  debugPrint("Manage subscriptions error: $e");
                                }
                              },
                              child: const Text("Cancel Subscription", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ] else ...[
                          if (standardPackages.isNotEmpty)
                            buildSection("STANDARD", standardPackages),
                          if (vipPackages.isNotEmpty)
                            buildSection("VIP", vipPackages),
                        ],

                        const SizedBox(height: 20),

                        /// 🔥 iOS REDEEM PROMO CODE SECTION
                        _buildIOSRedeemCodeOption(),
                      ],
                    ),
                  ),
                ),

                if (!isVip) ...[
                  vPad20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isAgreed,
                        onChanged: (value) {
                          setState(() {
                            isAgreed = value ?? false;
                          });
                        },
                      ),
                      const Text('I agree with '),
                      GestureDetector(
                        onTap: () async {
                          await _openUrl(
                            'https://chatter-matters.web.app/#/privacy-policy',
                          );
                        },
                        child: const Text(
                          "Terms of Use",
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                      const Text(" and "),
                      GestureDetector(
                        onTap: () async {
                          await _openUrl(
                            'https://chatter-matters.web.app/#/privacy-policy',
                          );
                        },
                        child: const Text(
                          "Privacy Policy",
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),

                  /// 🔥 SINGLE PURCHASE BUTTON
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.blue.shade300),
                        ),
                      ),
                      onPressed:
                          (selectedPackage == null || isLoading || !isAgreed)
                          ? null
                          : purchasePackage,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              selectedPackage == null
                                  ? "Select Plan"
                                  : "Continue (${selectedPackage!.storeProduct.priceString})",
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildIOSRedeemCodeOption() {
    if (!Platform.isIOS) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customLightPurple.withOpacity(0.05),
        border: Border.all(
          color: customLightPurple.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: customLightPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: customDarkPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Have a Promo Code?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: customDarkPurple,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Redeem your App Store offer code here.",
                  style: TextStyle(
                    fontSize: 12,
                    color: customDarkGray,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Purchases.presentCodeRedemptionSheet();
              } catch (e) {
                debugPrint("Redemption sheet error: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: customLightPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Redeem",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Have a coupon code?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    hintText: "Enter code",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isApplyingCoupon ? null : _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: isApplyingCoupon
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Apply"),
              ),
            ],
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    await Purchases.presentCodeRedemptionSheet();
                  } catch (e) {
                    debugPrint("Redemption sheet error: $e");
                  }
                },
                icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                label: const Text("Redeem iOS Promo Code"),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyCoupon() async {
    final code = couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => isApplyingCoupon = true);

    // Mock delay for coupon validation
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => isApplyingCoupon = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Coupon '$code' applied (Mock logic)")),
      );
    }
  }
}
