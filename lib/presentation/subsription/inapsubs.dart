import 'package:chatter_matter_app/application/user/auth_bloc.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/core/enums.dart';
import 'package:chatter_matter_app/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

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
        final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
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

    final result =
        await Purchases.purchasePackage(selectedPackage!);

    final userBloc = context.read<UserBloc>();
    final questionProvider = context.read<QuestionProvider>();

    final entitlements = result.customerInfo.entitlements;

    debugPrint("PURCHASE ENTITLEMENTS: ${entitlements.all}");

    if (entitlements.all['vip_plans']?.isActive == true) {
      debugPrint("VIP UNLOCKED");
      userBloc.updatesubscription(SubscriptionType.vip);

    } else if (entitlements.all['standard_plans']?.isActive == true) {
      debugPrint("STANDARD UNLOCKED");
      userBloc.updatesubscription(SubscriptionType.standard);

    } else {
      userBloc.updatesubscription(SubscriptionType.free);
    }

    await userBloc.fetchProfile(); // Ensure profile is updated from server
    await questionProvider.resetPaginator();

    if (entitlements.all['vip_plans']?.isActive == true) {
      await questionProvider.ensureMinimumQuestions(20);
    } else if (entitlements.all['standard_plans']?.isActive == true) {
      await questionProvider.ensureMinimumQuestions(10);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Purchase successful 🎉")),
    );

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
        ? [
            "Unlimited Access",
            "Premium Features",
            "Priority Support",
            "No Ads",
          ]
        : [
            "Limited Access",
            "Basic Features",
            "Ads Included",
          ];

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
                    const Icon(Icons.check,
                        size: 18, color: Colors.green),
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
            final isMonthly =
                pkg.packageType == PackageType.monthly;

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
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(label),

                        /// 🔥 BEST VALUE TAG
                        if (!isMonthly)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius:
                                  BorderRadius.circular(4),
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
    final isEmpty =
        standardPackages.isEmpty && vipPackages.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Purchase"),
        centerTitle: true,
      ),
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
                        if (standardPackages.isNotEmpty)
                          buildSection(
                              "STANDARD", standardPackages),

                        if (vipPackages.isNotEmpty)
                          buildSection("VIP", vipPackages),
                      ],
                    ),
                  ),
                ),
                
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
                    Text('I agree with '),
                    GestureDetector(
                      onTap: () async {
                        await _openUrl('https://chatter-matters.web.app/#/privacy-policy');
                      },
                      child: Text(
                        "Terms of Use",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    Text(" and "),
                    GestureDetector(
                      onTap: () async {
                        await _openUrl('https://chatter-matters.web.app/#/privacy-policy');
                      },
                      child: Text(
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
                        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10),side: BorderSide(color: Colors.blue.shade300) )
                      ),
                      onPressed:
                          (selectedPackage == null || isLoading || !isAgreed)
                              ? null
                              : purchasePackage,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
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
            ),
    );
  }
}