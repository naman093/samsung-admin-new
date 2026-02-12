import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';

import '../app_theme/app_colors.dart';

class CommonFlyout extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;
  final List<Widget> children;
  final Widget? icon;
  final bool Function()? canDismiss;

  const CommonFlyout({
    super.key,
    required this.title,
    this.description,
    this.onClose,
    this.children = const [],
    this.icon,
    this.canDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 680,
      height: double.infinity,
      decoration: BoxDecoration(
        // image: DecorationImage(
        //   image: AssetImage(AppAssets.flyoutBg),
        //   fit: BoxFit.cover,
        // ),
        color: AppColors.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize:
                              24, // Assuming a reasonable size for a title
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily:
                              'samsungsharpsans', // Consistent with other parts of the app
                        ),
                      ),
                      if (description != null)
                        Text(
                          description!,
                          style: AppTextStyles.rubik14w400().copyWith(
                            color: AppColors.labelTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                FlyoutCloseButton(
                  onTap: canDismiss != null
                      ? (canDismiss!() ? onClose : null)
                      : onClose,
                  icon: icon,
                  canDismiss: canDismiss,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsGeometry.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlyoutCloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? icon;
  final double? radius;
  final bool Function()? canDismiss;
  const FlyoutCloseButton({
    super.key,
    this.onTap,
    this.icon,
    this.radius,
    this.canDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (canDismiss != null) {
      return Obx(() {
        final canDismissValue = canDismiss!();
        return MouseRegion(
          cursor: canDismissValue
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: canDismissValue ? onTap : null,
            child: Opacity(
              opacity: canDismissValue ? 1.0 : 0.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius ?? 110),
                  gradient: const LinearGradient(
                    begin: Alignment(0, -0.4925),
                    end: Alignment(0, 1.2388),
                    colors: [
                      Color.fromRGBO(214, 214, 214, 0.2),
                      Color.fromRGBO(112, 112, 112, 0.2),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 8.15),
                      blurRadius: 18.21,
                    ),
                    BoxShadow(
                      color: Color(0x17000000),
                      offset: Offset(0, 33.07),
                      blurRadius: 33.07,
                    ),
                    BoxShadow(
                      color: Color(0x0D000000),
                      offset: Offset(0, 74.76),
                      blurRadius: 45.05,
                    ),
                    BoxShadow(
                      color: Color(0x03000000),
                      offset: Offset(0, 132.74),
                      blurRadius: 53.19,
                    ),
                    BoxShadow(
                      color: Color(0x00000000),
                      offset: Offset(0, 207.5),
                      blurRadius: 57.99,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius ?? 110),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8.625896453857422,
                      sigmaY: 8.625896453857422,
                    ),
                    child: CustomPaint(
                      painter: _CloseButtonPainter(radius: radius ?? 110),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child:
                            icon ??
                            const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(110),
            gradient: const LinearGradient(
              begin: Alignment(0, -0.4925),
              end: Alignment(0, 1.2388),
              colors: [
                Color.fromRGBO(214, 214, 214, 0.2),
                Color.fromRGBO(112, 112, 112, 0.2),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // 0px 8.15px 18.21px 0px #0000001A
                offset: Offset(0, 8.15),
                blurRadius: 18.21,
              ),
              BoxShadow(
                color: Color(0x17000000), // 0px 33.07px 33.07px 0px #00000017
                offset: Offset(0, 33.07),
                blurRadius: 33.07,
              ),
              BoxShadow(
                color: Color(0x0D000000), // 0px 74.76px 45.05px 0px #0000000D
                offset: Offset(0, 74.76),
                blurRadius: 45.05,
              ),
              BoxShadow(
                color: Color(0x03000000), // 0px 132.74px 53.19px 0px #00000003
                offset: Offset(0, 132.74),
                blurRadius: 53.19,
              ),
              BoxShadow(
                color: Color(0x00000000), // 0px 207.5px 57.99px 0px #00000000
                offset: Offset(0, 207.5),
                blurRadius: 57.99,
              ),
            ],
          ),
          // ClipRRect is needed to clip the BackdropFilter to the border radius
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius ?? 110),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8.625896453857422,
                sigmaY: 8.625896453857422,
              ),
              child: CustomPaint(
                painter: _CloseButtonPainter(radius: radius ?? 110),
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child:
                      icon ??
                      const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24, // Standard icon size
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButtonPainter extends CustomPainter {
  final double? radius;

  _CloseButtonPainter({this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius ?? 110),
    );

    // 1. Draw Inset Shadow
    // box-shadow: 2.19px -2.19px 2.19px 0px #00000040 inset;
    canvas.save();
    canvas.clipRRect(rrect);

    final Paint shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.19);

    final Path path = Path()
      ..addRect(Rect.fromLTWH(-50, -50, size.width + 100, size.height + 100))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    // Shift: 2.19px horizontal, -2.19px vertical
    canvas.translate(2.19, -2.19);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 2. Draw Gradient Border
    // border: 1.1px solid;
    // border-image-source: linear-gradient(180deg, rgba(242, 242, 242, 0.2) 0%, rgba(129, 129, 129, 0.2) 41.42%, rgba(255, 255, 255, 0.2) 100%);
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(242, 242, 242, 0.2),
          Color.fromRGBO(129, 129, 129, 0.2),
          Color.fromRGBO(255, 255, 255, 0.2),
        ],
        stops: [0.0, 0.4142, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
