import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/config/router/app_router.dart';
import '../../../../../../../core/utils/theme/app_color.dart';
import '../../../../../../../core/utils/theme/app_images.dart';
import '../view_model/driver_main_lay_out_view_model.dart';

class DriverMainLayoutView extends StatelessWidget {
  const DriverMainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverMainLayoutViewModel(),
      child: const DriverMainLayoutViewBody(),
    );
  }
}

class DriverMainLayoutViewBody extends StatelessWidget {
  const DriverMainLayoutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DriverMainLayoutViewModel>(context);

    return AutoTabsScaffold(
      homeIndex: 0,
      inheritNavigatorObservers: true,
      lazyLoad: true,
      routes: const [
        // DriverHomeRoute(),
        // DriverHistoryRoute(),
        // DriverEarningRoute(),
        // DriverProfileRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: viewModel.currentIndex,
            onTap: (index) {
              viewModel.setTabIndex(index);
              tabsRouter.setActiveIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textThird,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  viewModel.currentIndex == 0 ? SvgPath.homeFull : SvgPath.home,
                  width: 24,
                  height: 24,
                ),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  viewModel.currentIndex == 1 ? SvgPath.historyFull : SvgPath.history,
                  width: 24,
                  height: 24,
                ),
                label: 'السجل',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  viewModel.currentIndex == 2 ? SvgPath.earningFull : SvgPath.earning,
                  width: 24,
                  height: 24,
                ),
                label: 'الأرباح',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  viewModel.currentIndex == 3 ? SvgPath.profileFull : SvgPath.profile,
                  width: 24,
                  height: 24,
                ),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        );
      },
    );
  }
}