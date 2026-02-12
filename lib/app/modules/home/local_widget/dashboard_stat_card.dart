import 'package:flutter/material.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final int count;
  final String iconAsset;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(214, 214, 214, 0.04),
            Color.fromRGBO(112, 112, 112, 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3F4246), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 7.04),
            blurRadius: 15.73,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(214, 214, 214, 0.14),
                    Color.fromRGBO(112, 112, 112, 0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 7.04),
                    blurRadius: 15.73,
                  ),
                ],
              ),
              child: Center(
                child: AssetImageWidget(
                  imagePath: iconAsset,
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 13),
            // Make text area flexible so it can shrink with small widths
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.0,
                      letterSpacing: -0.02,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count.toString(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontSize: 26,
                      height: 1.0,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
