// import 'package:auto_route/auto_route.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AppGuard extends AutoRouteGuard {
//   @override
//   Future<void> onNavigation(
//     NavigationResolver resolver,
//     StackRouter router,
//   ) async {
//     final prefs = getIt<SharedPreferences>();
//
//     // Check if it's the user's first time.
//     final bool firstTime = prefs.getBool(Constants.firstTime) ?? true;
//     if (firstTime && resolver.route.path != PathConstants.onboarding) {
//       resolver.redirect(const OnBoardingRoute());
//       return;
//     }
//
//     // Check authentication
//     final String token = prefs.getString(Constants.tokenKey) ?? "";
//     if (token.isNotEmpty) {
//       // Redirect to the proper layout based on user type.
//       final int userType = prefs.getInt(Constants.userTypeKey) ?? 0;
//       resolver.redirect(
//         userType == 1 ? VendorMainLayoutRoute() : const UserMainLayoutRoute(),
//       );
//     } else {
//       resolver.next(true);
//     }
//   }
// }
