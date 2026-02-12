import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/base_layout.dart';

import '../../app_theme/textstyles.dart';
import '../constant/app_assets.dart';

class CommonWidget {
  static Widget isLoadingAndEmptyWidget({
    bool isLoadingValue = false,
    bool isEmpty = false,
    bool emptyIconShow = true,
    IconData? emptyIcon,
    String? emptyMsgText,
    Widget? widget,
    Color? colorCupertinoActivityIndicator,
  }) {
    if (isLoadingValue) {
      return SizedBox(
        height: Get.height * .55,
        child: Center(
          child: CupertinoActivityIndicator(
            color: colorCupertinoActivityIndicator ?? AppColors.white,
          ),
        ),
      );
    } else if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyIconShow) ...[
              SizedBox(height: 50),
              Icon(
                emptyIcon ?? Icons.history,
                size: 40,
                color: AppColors.white,
              ),
              SizedBox(height: 8),
            ],
            Text(
              emptyMsgText ?? 'Data not found!',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            if (emptyIconShow) SizedBox(height: 50),
          ],
        ),
      );
    } else {
      return widget ?? SizedBox();
    }
  }

  static Widget commonCardView({
    String? title,
    String? subTitle,
    required Widget child,
    Widget? bottomChild,
    bool showBackButton = false,
    ScrollPhysics? physics,
    bool isScrollable = true,
    shouldHaveTopSpace = true,
    EdgeInsets? padding,
  }) {
    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shouldHaveTopSpace ? SizedBox(height: 26) : SizedBox.shrink(),
          if (showBackButton && (Get.key.currentState?.canPop() ?? false))
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(89.48),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.2),
                            Color.fromRGBO(112, 112, 112, 0.2),
                          ],
                          stops: [-0.4925, 1.2388],
                        ),
                        border: Border.all(
                          width: 0.89,
                          color: const Color.fromRGBO(242, 242, 242, 0.2),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            offset: Offset(0, 6.65),
                            blurRadius: 14.86,
                          ),
                          BoxShadow(
                            color: Color(0x17000000),
                            offset: Offset(0, 26.97),
                            blurRadius: 26.97,
                          ),
                          BoxShadow(
                            color: Color(0x0D000000),
                            offset: Offset(0, 60.99),
                            blurRadius: 36.75,
                          ),
                          BoxShadow(
                            color: Color(0x03000000),
                            offset: Offset(0, 108.29),
                            blurRadius: 43.39,
                          ),
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(1.79, -1.79),
                            blurRadius: 1.79,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(89.48),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7.04, sigmaY: 7.04),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.chevron_left,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Return to previous page',
                      style: const TextStyle(
                        fontFamily: 'samsungsharpsans',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (title != null)
            Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: 'samsungsharpsans',
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 30,
                height: 24 / 30,
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          if (subTitle != null) ...[
            SizedBox(height: 16),
            Text(
              subTitle,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: 'samsungsharpsans',
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14,
                height: 22 / 14,
                letterSpacing: 0,
                color: Color(0xFFBDBDBD),
              ),
            ),
            SizedBox(height: 20),
          ],
          isScrollable ? child : Expanded(child: child),
          SizedBox(height: 26),
        ],
      );
    }

    return BaseLayout(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.dashboardContainerBackground,
          border: const Border(
            top: BorderSide(
              color: AppColors.dashboardContainerBorder,
              width: 1,
            ),
            right: BorderSide(
              color: AppColors.dashboardContainerBorder,
              width: 1,
            ),
            bottom: BorderSide.none,
            left: BorderSide.none,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topLeft: Radius.zero,
            bottomLeft: Radius.zero,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 7.43),
              blurRadius: 16.6,
            ),
          ],
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            Expanded(
              child: isScrollable
                  ? SingleChildScrollView(
                      physics: physics,
                      child: buildContent(),
                    )
                  : buildContent(),
            ),
            if (bottomChild != null) bottomChild,
          ],
        ),
      ),
    );
  }

  static Widget commonNetworkImageView({
    required String imageUrl,
    String? errorImageUrl,
    double? width,
    double? height,
    bool panEnabled = false,
    BoxFit? fit,
    BoxFit? errorImgBoxFit,
    BorderRadiusGeometry? borderRadius,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    return InteractiveViewer(
      panEnabled: panEnabled,
      minScale: 1.0,
      maxScale: 4.0,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: Image.network(
          imageUrl,
          width: width ?? double.infinity,
          height: height ?? 100,
          fit: fit ?? BoxFit.cover,
          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child;
                return Center(
                  child: isLoadingAndEmptyWidget(isLoadingValue: true),
                );
              },
          errorBuilder:
              errorBuilder ??
              (context, error, stackTrace) {
                return Image.asset(
                  errorImageUrl ?? AppAssets.imageNotFound,
                  width: width ?? double.infinity,
                  height: height ?? 100,
                  fit: errorImgBoxFit ?? BoxFit.cover,
                );
              },
        ),
      ),
    );
  }

  static Widget filterCountTextView({
    required int currentPage,
    required int perPage,
    required int totalCount,
  }) {
    int start = ((currentPage - 1) * perPage) + 1;
    int end = (currentPage * perPage);

    if (end > totalCount) {
      end = totalCount;
    }

    String text = totalCount == 0 ? '0 of 0' : '$start-$end of $totalCount';

    return Text(
      text,
      style: Theme.of(
        Get.context!,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  static Widget commonIconBtn({
    bool isBtnDisable = false,
    VoidCallback? onPressed,
    Widget? child,
    IconData? icon,
  }) {
    return IconButton(
      icon:
          child ??
          Icon(
            icon,
            color: isBtnDisable ? AppColors.gradientColor2 : AppColors.white,
          ),
      onPressed: isBtnDisable || onPressed == null ? null : onPressed,
    );
  }

  static Widget readMoreAndLessTextView({
    required String text,
    TextStyle? style,
    TextStyle? readMoreLessTextStyle,
  }) {
    return ReadMoreText(
      text,
      trimMode: TrimMode.Line,
      trimLines: 3,
      style: style ?? AppTextStyles.rubik16w400(),
      trimCollapsedText: ' Show More',
      trimExpandedText: ' Show Less',
      moreStyle:
          readMoreLessTextStyle ??
          TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
      lessStyle:
          readMoreLessTextStyle ??
          TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
    );
  }
}
