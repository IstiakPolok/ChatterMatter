import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/common/see_%20loading.dart';
import 'package:chatter_matter_app/common/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common_dialouge.dart';
import '../../providers/journal_provider.dart';
import '../setting/showcase_keys.dart';
import 'package:showcaseview/showcaseview.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final JournalProvider journalProvider = context.watch();

    // Debug print the entire journal list
    debugPrint(
      'JournalView Build: Total journals = ${journalProvider.journalList.length}',
    );
    for (int i = 0; i < journalProvider.journalList.length; i++) {
      final journal = journalProvider.journalList[i];
      debugPrint(
        '  [$i] Journal: ID = "${journal.id}", Question = "${journal.question}", Ans = "${journal.ans}"',
      );
    }

    return Column(
      children: [
        Showcase(
          key: ShowcaseKeys.journalPageKey,
          title: "📓 Step 6 — Your Journal",
          description: "All your saved journals will appear here.",
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
          child: Text("My Journal", style: heading()),
        ),

        Text(
          "Your conversation reflections",
          style: bodyMedium(color: customDarkGray),
        ),
        vPad10,
        Expanded(
          child: journalProvider.journalList.isEmpty
              ? journalProvider.isLoading
                    ? cLoading()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("You do not have any Journal Yet"),
                          IconButton(
                            onPressed: () async =>
                                journalProvider.resetPaginator(),
                            icon: Icon(Icons.refresh),
                          ),
                        ],
                      )
              : RefreshIndicator(
                  onRefresh: () async => journalProvider.resetPaginator(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    itemCount: journalProvider.journalList.length,
                    itemBuilder: (context, index) => _customTile(
                      ans: journalProvider.journalList[index].ans,
                      onDelete: () async {
                        final check = await showDeleteConfirmationDialog(
                          context,
                        );
                        debugPrint(
                          'JournalView: Delete confirmation dialog returned: $check',
                        );
                        if (check == true) {
                          final success = await journalProvider.deleteJournal(
                            journalId: journalProvider.journalList[index].id,
                          );
                          if (context.mounted) {
                            if (success == true) {
                              showToast(
                                context: context,
                                title: "Journal deleted successfully",
                                toastType: ToastType.success,
                              );
                            } else {
                              showToast(
                                context: context,
                                title: "Failed to delete journal",
                                toastType: ToastType.failed,
                              );
                            }
                          }
                        }
                      },
                      question: journalProvider.journalList[index].question,
                    ),
                  ),
                ),
        ),

        // Expanded(
        //   child: SingleChildScrollView(
        //     padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        //     child: Column(
        //       spacing: 15,
        //       children: [
        //         _customTile(),
        //         _customTile(),
        //         _customTile(),
        //         _customTile(),
        //         _customTile(),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

_customTile({
  required String question,
  required String ans,
  required VoidCallback onDelete,
}) {
  return Container(
    padding: EdgeInsets.all(13),
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(defaultRadius),
      color: customWhite,
      border: Border.all(color: customLightPurple),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today", style: bodySmall(color: customGray)),
            GestureDetector(
              // splashRadius: 1,
              onTap: onDelete,
              child: Icon(Icons.delete_forever, color: customRed, size: 20),
            ),
          ],
        ),

        vPad10,
        Text(question, style: titleSmall()),
        vPad10,
        Text(ans, style: bodyMedium(color: customDarkGray)),
      ],
    ),
  );
}
