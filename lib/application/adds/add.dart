import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

// if (Platform.isAndroid)
BannerAd myBanner = BannerAd(
  adUnitId: Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : "ca-app-pub-8703469882760831/3998217612", // your banner ad unit ID
  size: AdSize.largeBanner,
  request: AdRequest(),
  listener: BannerAdListener(
    onAdLoaded: (ad) {
      print('Banner loaded successfully: ${ad.responseInfo}');
    },
    onAdFailedToLoad: (ad, error) {
      print('Failed to load banner:');
      print('  Error code: ${error.code}');
      print('  Error message: ${error.message}');
      print('  Error domain: ${error.domain}');
      print('  Response info: ${error.responseInfo}');
      ad.dispose();
    },
  ),
);

// InterstitialAd? myInterstitial;
// bool isInterstitialLoaded = false;

// void loadInterstitial() {
//   InterstitialAd.load(
//     adUnitId: 'ca-app-pub-3940256099942544/1033173712', // TEST Interstitial ID
//     request: AdRequest(),
//     adLoadCallback: InterstitialAdLoadCallback(
//       onAdLoaded: (InterstitialAd ad) {
//         myInterstitial = ad;
//         isInterstitialLoaded = true;

//         // Setup full-screen content callbacks
//         myInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
//           onAdShowedFullScreenContent: (ad) => print('Interstitial shown'),
//           onAdDismissedFullScreenContent: (ad) {
//             print('Interstitial dismissed');
//             ad.dispose();
//             isInterstitialLoaded = false;
//             loadInterstitial(); // preload next ad
//           },
//           onAdFailedToShowFullScreenContent: (ad, error) {
//             print('Failed to show interstitial: $error');
//             ad.dispose();
//             isInterstitialLoaded = false;
//             loadInterstitial(); // preload next ad
//           },
//         );

//         print('Interstitial loaded');
//       },
//       onAdFailedToLoad: (LoadAdError error) {
//         print('Failed to load interstitial: $error');
//       },
//     ),
//   );
// }

// void showInterstitial() {
//   if (isInterstitialLoaded && myInterstitial != null) {
//     myInterstitial!.show();
//     isInterstitialLoaded = false;
//   } else {
//     print('Interstitial not ready yet');
//   }
// }
