// import 'package:auto_route/auto_route.dart';
// import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';
// import '../../router/app_router.gr.dart';
//
// @injectable
// class NetworkGuard extends AutoRouteGuard {
//   @override
//   Future<void> onNavigation(
//     NavigationResolver resolver,
//     StackRouter router,
//   ) async {
//     final networkStatus = GetIt.I<NetworkStatus>();
//     final isConnected = await networkStatus.isConnected();
//
//     if (!isConnected) {
//       router.push(
//         EmptyRefreshRoute(
//           animationType: LottieAnimationType.noConnection,
//           onRetry: () {
//             networkStatus.isConnected().then((connectedOnRetry) {
//               if (connectedOnRetry) {
//                 router.maybePop();
//                 resolver.next(true);
//               }
//             });
//           },
//         ),
//       );
//       return;
//     }
//     resolver.next(true);
//   }
// }
