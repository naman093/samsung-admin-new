import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final String? icon;
  final double? borderRadius;
  final EdgeInsets? padding;
  final bool isEnabled;
  final Color? bgColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final bool? isLoading;

  const CommonButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.bgColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.isLoading = false,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    this.isEnabled = true,
  }) : assert(padding != null, 'padding must not be null');

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              border: Border.all(color: borderColor ?? Colors.transparent),
              // Background Gradient applied to the main container
              gradient: bgColor != null
                  ? LinearGradient(colors: [bgColor!, bgColor!])
                  : const LinearGradient(
                      begin: Alignment(0, -0.4925), // -49.25%
                      end: Alignment(0, 1.2388), // 123.88%
                      colors: [
                        Color.fromRGBO(214, 214, 214, 0.4),
                        Color.fromRGBO(112, 112, 112, 0.4),
                      ],
                    ),
              // Shadows applied to the main container
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000), // 0px 7.43px 16.6px 0px #0000001A
                  offset: Offset(0, 7.43),
                  blurRadius: 16.6,
                ),
                BoxShadow(
                  color: Color(0x17000000), // 0px 30.15px 30.15px 0px #00000017
                  offset: Offset(0, 30.15),
                  blurRadius: 30.15,
                ),
                BoxShadow(
                  color: Color(0x0D000000), // 0px 68.16px 41.07px 0px #0000000D
                  offset: Offset(0, 68.16),
                  blurRadius: 41.07,
                ),
                BoxShadow(
                  color: Color(0x03000000), // 0px 121.02px 48.5px 0px #00000003
                  offset: Offset(0, 121.02),
                  blurRadius: 48.5,
                ),
                BoxShadow(
                  color: Color(
                    0x00000000,
                  ), // 0px 189.18px 52.87px 0px #00000000
                  offset: Offset(0, 189.18),
                  blurRadius: 52.87,
                ),
              ],
            ),

            // Shadows applied to the main container
            // ClipRRect is needed to clip the BackdropFilter to the border radius
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
                child: CustomPaint(
                  painter: _ButtonEffectsPainter(
                    borderRadius: borderRadius ?? 10,
                  ),
                  child: Padding(
                    padding:
                        padding ??
                        EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                    child: isLoading == true
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 5,
                            children: [
                              if (icon != null)
                                iconColor != null
                                    ? ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          iconColor!,
                                          BlendMode.srcIn,
                                        ),
                                        child: Image.asset(
                                          icon!,
                                          width: 18,
                                          height: 18,
                                        ),
                                      )
                                    : Image.asset(icon!, width: 18, height: 18),
                              Text(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor ?? Colors.white,
                                  fontFamily: 'samsungsharpsans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  height: 24 / 14,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
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

class _ButtonEffectsPainter extends CustomPainter {
  final double? borderRadius;

  _ButtonEffectsPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius ?? 10),
    );

    // 1. Draw Inset Shadow
    // CSS: box-shadow: 2px -2px 2px 0px #00000040 inset;
    canvas.save();
    canvas.clipRRect(rrect);

    final Paint shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final Path path = Path()
      ..addRect(Rect.fromLTWH(-50, -50, size.width + 100, size.height + 100))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    // Offset (2, -2) for shadow, meaning the "caster" is shifted (-2, 2) relative to hole?
    // If shadow is bottom-right (2, 2), we draw caster at (-2, -2).
    // CSS: horizontal 2px, vertical -2px.
    // Shift the hole caster.
    canvas.translate(2, -2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 2. Draw Gradient Border
    // border-image-source: linear-gradient(180deg, rgba(242, 242, 242, 0.2) 0%, rgba(129, 129, 129, 0.2) 41.42%, rgba(255, 255, 255, 0.2) 100%);
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
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
