import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_matter_app/common/colors.dart';
import 'package:chatter_matter_app/common/custom_buttons.dart';
import 'package:chatter_matter_app/common/custom_text_style.dart';
import 'package:chatter_matter_app/common/navigator.dart';
import 'package:chatter_matter_app/common/padding.dart';
import 'package:chatter_matter_app/presentation/subsription/inapsubs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/user/auth_bloc.dart';
import '../../common/common_dialouge.dart';
import '../../common/see_ loading.dart';
import '../../core/enums.dart';
import '../onbording/start_screen.dart';
import '../subsription/subscription_view.dart';
import 'age_group_view.dart';
import 'delete_account.dart';
import 'edit_password.dart';
import 'edit_profile.dart';
import 'privacy_support/security_privacy.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = context.watch();
    final profile = userBloc.profile;
    final isProfileLoading = userBloc.isLoadingProfile;
    final totalVisit = userBloc.profile?.totalVisited ?? 0;
    return Column(
      children: [
        Center(child: Text("Settings", style: heading())),
        vPad10,
        Expanded(
          child: isProfileLoading
              ? cLoading()
              : !isProfileLoading && profile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Unable to load data"),
                    IconButton(
                      onPressed: () => userBloc.fetchProfile(),
                      icon: Icon(Icons.refresh),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () => userBloc.fetchProfile(),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),

                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Profile".toUpperCase(),
                            style: titleMedium(
                              fontWeight: FontWeight.w500,
                              color: customDarkGray,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(color: customLightPurple),
                          ),
                          child: ListTile(
                            minTileHeight: 45,
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: customLightPurple,
                                  width: 2,
                                ),
                                image:
                                    (profile?.imageUrl != null &&
                                        profile!.imageUrl!.isNotEmpty)
                                    ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          profile.imageUrl!,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),

                            title: Text(profile?.name ?? "N/A"),
                            subtitle: Text(profile?.email ?? "N/A"),
                            trailing: SizedBox(
                              height: 40,
                              child: customFilledButton(
                                title: "Edit",
                                onTap: () {
                                  navigateTo(context, EditProfile());
                                },
                                isLoading: false,
                                width: 60,
                              ),
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () =>
                              animatedNavigateTo(context, SubscriptionView1()),
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: customLightPurple),
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  "assets/image/upgrade_tile_bg.png",
                                ),
                              ),
                            ),

                            child: Row(
                              spacing: 12,
                              children: [
                                Image.asset("assets/icons/setting_upgrade.png"),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Upgrade to Premium",
                                        style: titleSmall(color: customWhite),
                                      ),
                                      Text(
                                        "Unlock all features",
                                        style: bodyMedium(
                                          color: customDarkPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                        vPad10,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Current Status"),
                                      Row(
                                        children: [
                                          Text(
                                            "$totalVisit Days",
                                            style: titleLarge(),
                                          ),
                                          Icon(
                                            Icons.local_fire_department,
                                            color: customRed,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Total Entries"),
                                      Row(
                                        children: [
                                          Text("100", style: titleLarge()),
                                          Icon(
                                            Icons
                                                .local_fire_department_outlined,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // ConstrainedBox(constraints: constraints)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width =
                                      (constraints.maxWidth / 100) * totalVisit;
                                  return Stack(
                                    children: [
                                      Container(
                                        height: 10,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            defaultRadius,
                                          ),
                                          color: customLightGray,
                                        ),
                                      ),
                                      Container(
                                        height: 10,
                                        width: width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            defaultRadius,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xffFFFAB9),
                                              const Color(0xffFB64B6),
                                              const Color(0xffC27AFF),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              Center(child: Text("$totalVisit% of milestone")),
                            ],
                          ),
                        ),
                        vPad15,

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Settings".toUpperCase(),
                            style: titleMedium(
                              fontWeight: FontWeight.w500,
                              color: customDarkGray,
                            ),
                          ),
                        ),
                        _settingsTile(
                          icon: "assets/icons/noti.png",
                          title: "Push Notifications",
                          subTitle: "Daily reminders",
                          onTap: () {},
                          trailing: userBloc.isLoadingNotification
                              ? CircularProgressIndicator()
                              : Switch(
                                  value: profile?.pushNotification ?? false,
                                  onChanged: userBloc.isLoadingNotification
                                      ? null
                                      : (v) {
                                          userBloc.updateNotification(v);
                                        },
                                ),
                          baseColor: customGreen,
                        ),
                        _settingsTile(
                          icon: "assets/icons/lock.png",
                          title: "Change Password",
                          subTitle: "Ensuring your security",

                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          ),
                          onTap: () =>
                              animatedNavigateTo(context, EditPassword()),
                          baseColor: customGreen,
                        ),

                        _settingsTile(
                          icon: "assets/icons/support.png",
                          title: "Support & Legal",
                          subTitle: "Support & legal",
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          ),
                          onTap: () =>
                              animatedNavigateTo(context, SecurityPrivacy()),
                          baseColor: customGreen,
                        ),

                        _settingsTile(
                          icon: "assets/icons/security.png",
                          title: "Security & Privacy",
                          subTitle: "About your privacy",
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          ),
                          onTap: () =>
                              animatedNavigateTo(context, SecurityPrivacy()),
                          baseColor: customGreen,
                        ),
                        _settingsTile(
                          icon: "assets/icons/age.png",
                          title: "Age Group",
                          subTitle: "Select your age group",
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          ),
                          onTap: () =>
                              animatedNavigateTo(context, AgeGroupView()),
                          baseColor: customGreen,
                        ),

                        Card(
                          elevation: 0,
                          color: customLightPurple.withOpacity(.2),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: customLightPurple),
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: customDarkPurple,
                            ),
                            onTap: () async {
                              final check = await showLogoutConfirmationDialog(
                                context,
                              );
                              if (check == true && context.mounted) {
                                userBloc.logout();
                                navigateReplaceAll(context, StartScreen());
                              }
                            },
                            // contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            // minTileHeight: 45,
                            title: Text(
                              "Log Out",
                              style: titleSmall(color: customDarkPurple),
                            ),
                          ),
                        ),

                        vPad20,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Danger Zone".toUpperCase(),
                            style: titleMedium(
                              fontWeight: FontWeight.w500,
                              color: customRed,
                            ),
                          ),
                        ),

                        customOutlinedButton(
                          title: "Delete Account",
                          onTap: () => navigateTo(context, DeleteAccountView()),
                          isLoading: false,
                          baseColor: customRed,
                          width: double.infinity,
                        ),
                        vPad35,
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

_settingsTile({
  required String title,
  required String subTitle,
  required Color baseColor,
  required Widget trailing,
  required VoidCallback onTap,
  required String icon,
}) {
  return Card(
    elevation: 0,
    color: customWhite,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: customLightPurple),
      borderRadius: BorderRadius.circular(defaultRadius),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Image.asset(icon),
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      minTileHeight: 45,
      title: Text(title),
      subtitle: Text(subTitle),
      trailing: trailing,
    ),
  );
}
