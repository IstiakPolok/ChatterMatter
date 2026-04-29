// import '../../core/enums.dart';

// class AppUser {
//   final String uid;
//   final String name;
//   final String email;
//   final String? imageUrl;
//   final int age;

//   final String provider;

//   // Subscription
//   final SubscriptionType subscriptionType;
//   final DateTime? subscriptionStartedAt;
//   final DateTime? subscriptionEndsAt;
//   final int totalVisited;
//   List<String> selectedCategories;
//   List<String> favoriteQuestionIds;

//   // final DateTime createdAt;
//   // final int updatedAt;
//   // final int? lastLoginAt;

//   final UserRole? role;

//   final bool? isEmailVerified;
//   final bool isActive;
//   bool pushNotification;

//   AppUser({
//     required this.uid,
//     required this.name,
//     required this.email,
//     this.imageUrl,
//     required this.totalVisited,
//     required this.age,
//     required this.provider,
//     required this.subscriptionType,
//     this.subscriptionStartedAt,
//     this.subscriptionEndsAt,
//     // required this.createdAt,
//     // required this.updatedAt,
//     // this.lastLoginAt,
//     this.role,
//     required this.selectedCategories,
//     this.isEmailVerified,
//     required this.isActive,
//     required this.pushNotification,
//     required this.favoriteQuestionIds,
//   });

//   /// FROM JSON
//   factory AppUser.fromJson(Map<String, dynamic> json) {
//     DateTime? parseTimestamp(Map<String, dynamic> ts) {
//       try {
//         final seconds = ts['_seconds'] as int? ?? 0;
//         final nanoseconds = ts['_nanoseconds'] as int? ?? 0;
//         return DateTime.fromMillisecondsSinceEpoch(
//           seconds * 1000 + (nanoseconds / 1000000).round(),
//         );
//       } catch (e) {
//         null;
//       }
//       return null;
//     }

//     return AppUser(
//       uid: json['uid'],
//       name: json['name'],
//       email: json['email'],
//       totalVisited: json['totalVisited'] ?? 0,
//       imageUrl: json['imageUrl'],
//       age: json['age'] ?? 0,
//       selectedCategories:
//           (json['selectedCategories'] as List<dynamic>?)
//               ?.map((e) => e as String)
//               .toList() ??
//           [],
//       favoriteQuestionIds:
//           (json['favoriteQuestionIds'] as List<dynamic>?)
//               ?.map((e) => e as String)
//               .toList() ??
//           [],
//       provider: json['provider'],
//       subscriptionType: SubscriptionType.values.byName(
//         json['subscriptionType'],
//       ),
//       subscriptionStartedAt: json['subscriptionStartedAt'] != null
//           ? parseTimestamp(json['subscriptionStartedAt'])
//           : null,
//       subscriptionEndsAt: json['subscriptionEndsAt'] != null
//           ? parseTimestamp(json['subscriptionEndsAt'])
//           : null,
//       // createdAt: (json['createdAt'] as Timestamp).toDate(),
//       // updatedAt: json['updatedAt'],
//       // lastLoginAt: json['lastLoginAt'],
//       role: json['role'] != null ? UserRole.values.byName(json['role']) : null,
//       isEmailVerified: json['isEmailVerified'],
//       isActive: json['isActive'] ?? true,
//       pushNotification: json['pushNotification'] ?? false,
//     );
//   }

//   /// TO JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'uid': uid,
//       'name': name,
//       //  'email': email,
//       'imageUrl': imageUrl,
//       'age': age,
//       // 'provider': provider.name,
//       // 'subscriptionType': subscriptionType.name,
//       //  'subscriptionStartedAt': subscriptionStartedAt,
//       // 'subscriptionEndsAt': subscriptionEndsAt,

//       // 'updatedAt': updatedAt,
//       // 'lastLoginAt': lastLoginAt,
//       // 'role': role?.name,
//       //  'isEmailVerified': isEmailVerified,
//       // 'isActive': isActive,
//       'pushNotification': pushNotification,
//     };
//   }
// }





import '../../core/enums.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? imageUrl;
  final int age;

  final String provider;

  // Subscription
  final SubscriptionType subscriptionType;
  final DateTime? subscriptionStartedAt;
  final DateTime? subscriptionEndsAt;

  final int totalVisited;

  List<String> selectedCategories;
  List<String> favoriteQuestionIds;

  final UserRole? role;

  final bool? isEmailVerified;
  final bool isActive;

  bool pushNotification;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.totalVisited,
    required this.age,
    required this.provider,
    required this.subscriptionType,
    this.subscriptionStartedAt,
    this.subscriptionEndsAt,
    required this.selectedCategories,
    this.role,
    this.isEmailVerified,
    required this.isActive,
    required this.pushNotification,
    required this.favoriteQuestionIds,
  });

  /// ✅ COPY WITH (🔥 IMPORTANT)
  AppUser copyWith({
    SubscriptionType? subscriptionType,
    DateTime? subscriptionStartedAt,
    DateTime? subscriptionEndsAt,
    List<String>? selectedCategories,
    List<String>? favoriteQuestionIds,
    bool? pushNotification,
  }) {
    return AppUser(
      uid: uid,
      name: name,
      email: email,
      imageUrl: imageUrl,
      totalVisited: totalVisited,
      age: age,
      provider: provider,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionStartedAt:
          subscriptionStartedAt ?? this.subscriptionStartedAt,
      subscriptionEndsAt: subscriptionEndsAt ?? this.subscriptionEndsAt,
      selectedCategories:
          selectedCategories ?? List.from(this.selectedCategories),
      favoriteQuestionIds:
          favoriteQuestionIds ?? List.from(this.favoriteQuestionIds),
      role: role,
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      pushNotification: pushNotification ?? this.pushNotification,
    );
  }

  /// FROM JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    DateTime? parseTimestamp(Map<String, dynamic>? ts) {
      if (ts == null) return null;
      try {
        final seconds = ts['_seconds'] as int? ?? 0;
        final nanoseconds = ts['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      } catch (_) {
        return null;
      }
    }

    return AppUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      totalVisited: json['totalVisited'] ?? 0,
      imageUrl: json['imageUrl'],
      age: json['age'] ?? 0,
      selectedCategories:
          (json['selectedCategories'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      favoriteQuestionIds:
          (json['favoriteQuestionIds'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      provider: json['provider'] ?? '',
      subscriptionType: SubscriptionType.values.byName(
        json['subscriptionType'] ?? 'free',
      ),
      subscriptionStartedAt:
          parseTimestamp(json['subscriptionStartedAt']),
      subscriptionEndsAt:
          parseTimestamp(json['subscriptionEndsAt']),
      role: json['role'] != null
          ? UserRole.values.byName(json['role'])
          : null,
      isEmailVerified: json['isEmailVerified'],
      isActive: json['isActive'] ?? true,
      pushNotification: json['pushNotification'] ?? false,
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'age': age,
      'pushNotification': pushNotification,
    };
  }
}