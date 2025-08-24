import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package
import 'package:provider/provider.dart';
import '../../../../../core/config/router/app_router.dart';
import '../../../../../core/utils/theme/app_color.dart';
import '../view_model/main_lay_out_view_model.dart';

@RoutePage()
class MainLayoutView extends StatelessWidget {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainLayoutViewModel(),
      child: const MainLayoutViewBody(),
    );
  }
}

class MainLayoutViewBody extends StatelessWidget {
  const MainLayoutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainLayoutViewModel>(context);

    return AutoTabsScaffold(
      homeIndex: 0,
      inheritNavigatorObservers: true,
      lazyLoad: true,
      routes: const [
        HomeRoute(),
        CreatePostRoute(),
        StoryRoute(),
        ProfileRoute()
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
                icon: Icon(
                  viewModel.currentIndex == 0
                      ? CupertinoIcons.house_fill
                      : CupertinoIcons.house,
                  size: 24,
                  color: viewModel.currentIndex == 0
                      ? AppColors.primary
                      : AppColors.textThird,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  viewModel.currentIndex == 1
                      ? CupertinoIcons.plus_square_fill
                      : CupertinoIcons.plus_square,
                  size: 24,
                  color: viewModel.currentIndex == 1
                      ? AppColors.primary
                      : AppColors.textThird,
                ),
                label: 'Create Post',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  viewModel.currentIndex == 2
                      ? CupertinoIcons.play_circle_fill
                      : CupertinoIcons.play_circle,
                  size: 24,
                  color: viewModel.currentIndex == 2
                      ? AppColors.primary
                      : AppColors.textThird,
                ),
                label: 'Stories',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  viewModel.currentIndex == 3
                      ? CupertinoIcons.person_fill
                      : CupertinoIcons.person,
                  size: 24,
                  color: viewModel.currentIndex == 3
                      ? AppColors.primary
                      : AppColors.textThird,
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}