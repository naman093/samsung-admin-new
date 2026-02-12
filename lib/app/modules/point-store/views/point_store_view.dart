import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_flyout.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/modules/point-store/local_widget/create_edit_product.dart';
import 'package:samsung_admin_main_new/app/modules/point-store/local_widget/product_card.dart';
import '../../../common/widgets/common_widget.dart';
import '../controllers/point_store_controller.dart';

class PointStoreView extends GetView<PointStoreController> {
  const PointStoreView({super.key});

  void _openCreateProductFlyout() {
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Obx(
          () => PopScope(
            canPop: !controller.isLoading.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: CommonFlyout(
                  title: 'newProduct'.tr,
                  description: 'systemActivity'.tr,
                  onClose: () => Navigator.of(context).pop(),
                  canDismiss: () => !controller.isLoading.value,
                  children: [CreateEditProduct(controller: controller)],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: 'products'.tr,
      subTitle: 'systemActivity'.tr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height: subtract title (30 + 16), subtitle (14 + 16 + 20), and padding (26 * 2)
          final availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight - 30 - 16 - 14 - 16 - 20 - 52
              : MediaQuery.of(context).size.height * 0.7;

          final scrollHeight = availableHeight > 0 ? availableHeight : 600.0;
          return Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    // width: MediaQuery.of(context).size.width * 0.65,
                    child: SearchTextField(
                      hintText: 'search'.tr,
                      onChanged: (value) {
                        controller.fetchProducts(searchTerm: value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: CommonButton(
                      text: 'createProduct'.tr,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      onTap: () {
                        controller.isEditing.value = false;
                        controller.clearAllFields();
                        _openCreateProductFlyout();
                      },
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() {
                      return CommonWidget.isLoadingAndEmptyWidget(
                        isLoadingValue: controller.isLoading.value,
                        emptyMsgText: 'noFilesFound'.tr,
                        isEmpty: controller.productList.isEmpty,
                        widget: SizedBox(
                          height: scrollHeight,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification) {
                                final metrics = notification.metrics;
                                final maxScroll = metrics.maxScrollExtent;
                                final currentScroll = metrics.pixels;
                                const threshold = 200.0;

                                if (currentScroll >= maxScroll - threshold) {
                                  controller.loadMoreProducts();
                                }
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              child: Column(
                                spacing: 20,
                                children: [
                                  ...List.generate(
                                    controller.productList.length,
                                    (index) {
                                      final productModel =
                                          controller.productList[index];
                                      return ProductCard(
                                        selected:
                                            controller
                                                .selectedProduct
                                                .value
                                                ?.id ==
                                            productModel.id,
                                        productModel: productModel,
                                        controller: controller,
                                        onDelete: () => controller
                                            .clickOnDeleteBtn(productModel.id),
                                        onEdit: () {
                                          controller.prefillFormForEdit(
                                            productModel,
                                          );
                                          controller.isEditing.value = true;
                                          _openCreateProductFlyout();
                                        },
                                      );
                                    },
                                  ),
                                  Obx(
                                    () => controller.isLoadingMore.value
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Obx(() {
                    return controller.isLoading.value
                        ? SizedBox()
                        : SizedBox(
                            height: scrollHeight,
                            child: CommonWidget.commonNetworkImageView(
                              imageUrl:
                                  controller.selectedProduct.value?.imageUrl ??
                                  '',
                              width: 240,
                              borderRadius: BorderRadius.circular(16),
                              fit: BoxFit.fitWidth,
                              errorImgBoxFit: BoxFit.contain,
                            ),
                          );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
