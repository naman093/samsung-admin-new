import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/header.dart';
import 'package:samsung_admin_main_new/app/common/sidebar.dart';
import '../app_theme/app_colors.dart';
import 'constant/app_assets.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;

  const BaseLayout({super.key, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  // Create the GlobalKey once in the state, not on every build
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobileOrTablet = width < 750;
    if (isMobileOrTablet) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 41.0841,
                height: 38.2984,
                child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
              ),
              const SizedBox(width: 8),
              Text(
                'sCommunity'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18.55,
                  fontWeight: FontWeight.w700,
                  height: 53.01 / 18.55,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          titleSpacing: 0,
          centerTitle: false,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: AppColors.white),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        drawer: Sidebar(),
        body: widget.child,
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Row(
          children: [
            Sidebar(),
            Expanded(
              child: Column(
                children: [
                  const CommonHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
