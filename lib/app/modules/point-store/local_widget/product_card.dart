import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/models/store_product_model.dart';
import 'package:samsung_admin_main_new/app/modules/point-store/controllers/point_store_controller.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';
import '../../prod-orders/controllers/prod_orders_controller.dart';

class ProductCard extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? selected;
  final StoreProductModel? productModel;
  final PointStoreController controller;

  const ProductCard({
    super.key,
    this.onEdit,
    this.onDelete,
    this.selected,
    this.productModel,
    required this.controller,
  });

  Widget _chipEvent({required String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 7.864322662353516,
          sigmaY: 7.864322662353516,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(214, 214, 214, 0.4),
                Color.fromRGBO(112, 112, 112, 0.4),
              ],
              stops: [-0.4925, 1.2388],
            ),
            borderRadius: BorderRadius.circular(100),
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
                color: Color(0x00000000), // 0px 189.18px 52.87px 0px #00000000
                offset: Offset(0, 189.18),
                blurRadius: 52.87,
              ),
            ],
          ),
          child: Text(
            title,
            style: AppTextStyles.rubik14w400().copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _detailIcomCont({required String title, String? value, String? icon}) {
    return Row(
      spacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF20AEFE), // #20AEFE
                Color(0xFF135FFF), // #135FFF
              ],
              stops: [0.0041, 1.0],
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: AssetImageWidget(imagePath: icon, width: 10, height: 10),
        ),
        Text(title, style: AppTextStyles.rubik14w400()),
        if (value != null) Text(value, style: AppTextStyles.rubik14w400()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          controller.setSelectedProduct(productModel!);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: (selected == true
                  ? AppColors.white
                  : AppColors.eventCardBorderColor),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.eventCardBgColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 17,
                  children: [
                    CommonWidget.commonNetworkImageView(
                      imageUrl: productModel?.imageUrl ?? '',
                      width: 133,
                      height: 137,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 11,
                            children: [
                              _chipEvent(title: '23 Remaining'),
                              _chipEvent(
                                title: controller.formatEventDate(
                                  productModel?.endDate,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            productModel?.name ?? '',
                            style: AppTextStyles.rubik16w400(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            productModel?.description ?? 'No Description',
                            style: AppTextStyles.rubik14w400(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            spacing: 20,
                            children: [
                              _detailIcomCont(
                                title: 'Credit:',
                                value:
                                    productModel?.costPoints.toString() ?? '',
                                icon: AppAssets.creditIcon,
                              ),
                              _detailIcomCont(
                                title: 'Points:',
                                value:
                                    productModel?.costPoints.toString() ?? '',
                                icon: AppAssets.sidebarPointStore,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.darkGreyColor,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'confirm') {
                    onDelete?.call();
                  } else if (value == 'viewOrders') {
                    Get.delete<ProdOrdersController>();
                    Get.lazyPut(() => ProdOrdersController());
                    Get.toNamed(
                      Routes.PRODUCT_ORDERS,
                      parameters: {'id': productModel?.id ?? ''},
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'confirm',
                    child: Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(214, 214, 214, 0.2),
                                Color.fromRGBO(112, 112, 112, 0.2),
                              ],
                              stops: [-0.4925, 1.2388],
                            ),
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(242, 242, 242, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                offset: Offset(0, 3.57),
                                blurRadius: 7.97,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.trashIcon,
                            width: 10,
                            color: AppColors.white,
                            height: 10,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Text('delete'.tr, style: AppTextStyles.rubik12w400()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(214, 214, 214, 0.2),
                                Color.fromRGBO(112, 112, 112, 0.2),
                              ],
                              stops: [-0.4925, 1.2388],
                            ),
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(242, 242, 242, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                offset: Offset(0, 3.57),
                                blurRadius: 7.97,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.editIcon,
                            width: 10,
                            color: AppColors.white,
                            height: 10,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Text('edit'.tr, style: AppTextStyles.rubik12w400()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'viewOrders',
                    child: Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(214, 214, 214, 0.2),
                                Color.fromRGBO(112, 112, 112, 0.2),
                              ],
                              stops: [-0.4925, 1.2388],
                            ),
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(242, 242, 242, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                offset: Offset(0, 3.57),
                                blurRadius: 7.97,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.docomentText,
                            width: 10,
                            color: AppColors.white,
                            height: 10,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Text(
                          'viewOrders'.tr,
                          style: AppTextStyles.rubik12w400(),
                        ),
                      ],
                    ),
                  ),
                ],
                child: AssetImageWidget(
                  imagePath: AppAssets.imagesIcMoreIcon,
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
