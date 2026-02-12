import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';

import '../../../common/widgets/custom_time_interval_picker.dart';
import '../../../models/promotions_model.dart';
import '../../../repository/promotions_repo.dart';

enum PromotionFrequencyType { oneTime, setInterval }

class PromotionsController extends GetxController {
  final repoPromotions = Get.find<PromotionsRepo>();

  final isLoading = false.obs;
  final isCreating = false.obs;

  final isAlreadyFileUploaded = false.obs;

  RxList<PromotionModel> promotionsList = <PromotionModel>[].obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final intervalController = TextEditingController();
  final intervalDisplayController = TextEditingController();

  final selectedBackgroundImage = Rx<PlatformFile?>(null);

  final titleError = ''.obs;
  final descriptionError = ''.obs;
  final imageError = ''.obs;
  final intervalError = ''.obs;

  final selectedFrequencyType = PromotionFrequencyType.oneTime.obs;

  final isEditing = false.obs;
  final editingPromotionId = ''.obs;

  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    await fetchPromotions();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchPromotions({String? searchTerm}) async {
    isLoading.value = true;
    try {
      scrollController = ScrollController();
      final response = await repoPromotions.getPromotionsWithPagination(
        searchTerm: searchTerm ?? '',
      );
      promotionsList.value = response.data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrUpdatePromotion() async {
    _clearErrors();
    if (!_validate()) return;
    isCreating.value = true;
    try {
      final model = PromotionModel(
        id: isEditing.value
            ? editingPromotionId.value
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        backgroundImageUrl: selectedBackgroundImage.value?.name,
        frequency: selectedFrequencyType.value == PromotionFrequencyType.oneTime
            ? 'one_time'
            : 'interval',
        intervalDuration:
            selectedFrequencyType.value == PromotionFrequencyType.setInterval
            ? intervalController.text.trim()
            : null,
        isActive: true,
        createdBy: 'admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      Result response;
      if (isEditing.value) {
        response = await PromotionsRepo.updatePromotion(
          model: model,
          imageBytes: selectedBackgroundImage.value?.bytes,
          imageName: selectedBackgroundImage.value?.name,
        );
      } else {
        response = await PromotionsRepo.createPromotion(
          model: model,
          imageBytes: selectedBackgroundImage.value?.bytes,
          imageName: selectedBackgroundImage.value?.name,
        );
      }
      if (response.isSuccess) {
        CommonSnackbar.success(
          isEditing.value
              ? 'Promotions Update Successfully'
              : 'Promotions Create Successfully',
        );
        await fetchPromotions();
        clearAllFields();
        Get.back();
      }
    } catch (e) {
      CommonSnackbar.error(
        isEditing.value
            ? 'failedToUpdatePromotion'.tr
            : 'failedToCreatePromotion'.tr,
      );
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await repoPromotions.deletePromotion(id);
      promotionsList.removeWhere((e) => e.id == id);
    } catch (_) {
      CommonSnackbar.error('failedToDeletePromotion'.tr);
    }
  }

  void prefillForEdit(PromotionModel promotion) {
    _clearErrors();
    isEditing.value = true;
    editingPromotionId.value = promotion.id;

    titleController.text = promotion.title;
    descriptionController.text = promotion.description ?? '';
    intervalController.text = promotion.intervalDuration ?? '';
    updateFormattedIntervalDisplay();
    isAlreadyFileUploaded.value =
        promotion.backgroundImageUrl != null &&
        promotion.backgroundImageUrl!.isNotEmpty;
    selectedBackgroundImage.value = null;
    selectedFrequencyType.value = promotion.isInterval
        ? PromotionFrequencyType.setInterval
        : PromotionFrequencyType.oneTime;
  }

  bool _validate() {
    bool hasError = false;

    if (titleController.text.trim().isEmpty) {
      titleError.value = 'titleRequired'.tr;
      hasError = true;
    }

    if (descriptionController.text.trim().isEmpty) {
      descriptionError.value = 'descriptionRequired'.tr;
      hasError = true;
    }

    if ((!isEditing.value && selectedBackgroundImage.value == null) ||
        (isEditing.value &&
            !isAlreadyFileUploaded.value &&
            selectedBackgroundImage.value == null)) {
      imageError.value = 'backgroundImageRequired'.tr;
      hasError = true;
    }

    if (selectedFrequencyType.value == PromotionFrequencyType.setInterval &&
        intervalController.text.trim().isEmpty) {
      intervalError.value = 'intervalRequired'.tr;
      hasError = true;
    }

    return !hasError;
  }

  void _clearErrors() {
    titleError.value = '';
    descriptionError.value = '';
    imageError.value = '';
    intervalError.value = '';
  }

  void clearAllFields() {
    titleController.clear();
    descriptionController.clear();
    intervalController.clear();
    intervalDisplayController.clear();
    selectedBackgroundImage.value = null;

    isAlreadyFileUploaded.value = false;
    isEditing.value = false;
    editingPromotionId.value = '';
    selectedFrequencyType.value = PromotionFrequencyType.oneTime;
  }

  void updateFormattedIntervalDisplay() {
    final formatted = _formatIntervalForDisplay(intervalController.text);
    intervalDisplayController.text = formatted;
  }

  String _formatIntervalForDisplay(String intervalValue) {
    if (intervalValue.isEmpty) return '';

    final intervalData = CustomTimeIntervalPicker.parseInterval(intervalValue);
    final days = intervalData['days'] ?? 0;
    final hours = intervalData['hours'] ?? 0;
    final minutes = intervalData['minutes'] ?? 0;

    final parts = <String>[];
    if (days > 0) {
      parts.add('$days ${days == 1 ? 'day'.tr : 'days'.tr}');
    }
    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour'.tr : 'hours'.tr}');
    }
    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? 'minute'.tr : 'minutes'.tr}');
    }

    return parts.isEmpty ? '' : parts.join(', ');
  }
}
