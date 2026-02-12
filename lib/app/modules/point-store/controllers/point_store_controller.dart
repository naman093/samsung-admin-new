import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/common_dialogs/confirmation_dialog.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/store_product_model.dart';
import 'package:samsung_admin_main_new/app/repository/point_store_repo.dart';

class PointStoreController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final productList = <StoreProductModel>[].obs;
  final count = 0.obs;
  final totalCount = 0.obs;
  final totalPages = 1.obs;
  final currentPage = 1.obs;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final endDateController = TextEditingController();
  final costInPointsController = TextEditingController();
  final Rxn<StoreProductModel> selectedProduct = Rxn<StoreProductModel>();
  final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> explanatoryVideoOptionalFile = Rx<PlatformFile?>(
    null,
  );
  final Rx<bool> isEditing = false.obs;
  final Rx<String> editingContentId = ''.obs;
  final Rx<String> existingImageUrl = ''.obs;
  final Rx<String> existingVideoUrl = ''.obs;
  final Rx<bool> videoRemovedByUser = false.obs;
  String _originalVideoUrl = '';
  final titleError = ''.obs;
  final costInPointsError = ''.obs;
  final endDateError = ''.obs;
  final imageError = ''.obs;
  final descriptionError = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchProducts();
  }

  final pointStoreRepo = Get.find<PointStoreRepo>();

  String formatEventDate(String? dob) {
    if (dob == null) return 'No event date';
    return '${dob.split('T')[0].split('-')[2].padLeft(2, '0')}/${dob.split('T')[0].split('-')[1].padLeft(2, '0')}/${dob.split('T')[0].split('-')[0]}';
  }

  void setSelectedProduct(StoreProductModel product) {
    selectedProduct.value = product;
  }

  void clearAllFields() {
    titleController.text = '';
    titleError.value = '';
    descriptionController.text = '';
    descriptionError.value = '';
    costInPointsController.text = '';
    costInPointsError.value = '';
    endDateController.text = '';
    endDateError.value = '';
    isEditing.value = false;
    selectedFile.value = null;
    explanatoryVideoOptionalFile.value = null;
    existingImageUrl.value = '';
    existingVideoUrl.value = '';
    _originalVideoUrl = '';
    videoRemovedByUser.value = false;
    imageError.value = '';
    editingContentId.value = '';
  }

  void clickOnDeleteBtn(String contentId) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisProduct'.tr,
      onPressed: isLoading.value ? null : () => deleteProduct(contentId),
    );
  }

  void prefillFormForEdit(StoreProductModel event) {
    titleError.value = '';
    costInPointsError.value = '';
    endDateError.value = '';
    imageError.value = '';
    isEditing.value = true;
    editingContentId.value = event.id;
    titleController.text = event.name;
    descriptionController.text = event.description ?? '';
    endDateController.text = formatEventDate(event.endDate);
    costInPointsController.text = event.costPoints.toString();
    existingImageUrl.value = event.imageUrl ?? '';
    existingVideoUrl.value = event.descriptionVideoUrl ?? '';
    _originalVideoUrl = event.descriptionVideoUrl ?? '';
    videoRemovedByUser.value = false;
    selectedFile.value = null;
    explanatoryVideoOptionalFile.value = null;
  }

  Future<void> fetchProducts({String? searchTerm}) async {
    currentPage.value = 1;
    isLoading.value = true;
    try {
      StoreProductListResponse response = await pointStoreRepo
          .fetchStoreProductListWithPagination(
            pageNumber: currentPage.value,
            perPage: 10,
            searchTerm: searchTerm ?? '',
          );

      productList.value = response.data;
      totalCount.value = response.totalCount;
      totalPages.value = response.totalPages;
      if (productList.isNotEmpty) {
        selectedProduct.value = productList.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts({String searchTerm = ''}) async {
    // Don't load more if already loading or no more pages
    if (isLoadingMore.value) return;
    if (currentPage.value >= totalPages.value) return;

    isLoadingMore.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final response = await pointStoreRepo.fetchStoreProductListWithPagination(
        pageNumber: nextPage,
        perPage: 10,
        searchTerm: searchTerm,
      );

      // Append new items
      if (response.data.isNotEmpty) {
        productList.addAll(response.data);
        currentPage.value = response.pageNumber;
        totalCount.value = response.totalCount;
        totalPages.value = response.totalPages;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    try {
      final response = await pointStoreRepo.deleteProduct(id);
      if (response == true) {
        Get.back();
        fetchProducts();
        CommonSnackbar.success('productDeletedSuccessfully'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct() async {
    titleError.value = '';
    costInPointsError.value = '';
    endDateError.value = '';
    imageError.value = '';
    descriptionError.value = '';
    bool hasError = false;

    if (titleController.text.isEmpty) {
      titleError.value = 'titleIsRequired'.tr;
      hasError = true;
    }

    if (descriptionController.text.trim().isNotEmpty) {
      final words =
          descriptionController.text.trim().split(RegExp(r'\s+')).length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }

    if (costInPointsController.text.isEmpty) {
      costInPointsError.value = 'costIsRequired'.tr;
      hasError = true;
    }

    if (endDateController.text.isEmpty) {
      endDateError.value = 'validityIsRequired'.tr;
      hasError = true;
    }

    if (selectedFile.value == null && existingImageUrl.value.isEmpty) {
      imageError.value = 'imageRequired'.tr;
      hasError = true;
    }

    if (hasError) {
      return;
    }

    final date = DateFormat('dd/MM/yyyy').parse(endDateController.text);
    try {
      isLoading.value = true;
      final result = await PointStoreRepo.updateProduct(
        editingContentId.value,
        titleController.text,
        descriptionController.text,
        date.toIso8601String(),
        int.parse(costInPointsController.text),
        selectedFile.value?.bytes,
        selectedFile.value?.name,
        explanatoryVideoOptionalFile.value?.bytes,
        explanatoryVideoOptionalFile.value?.name,
        _originalVideoUrl,
        videoRemovedByUser.value,
      );
      if (result.isSuccess) {
        Get.back();
        fetchProducts();
        CommonSnackbar.success('productUpdatedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('productUpdateFailed'.tr);
      }
    } catch (e) {
      CommonSnackbar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String formatDOB(DateTime? dob) {
    if (dob == null) return '-';
    return '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
  }

  void setSelectedFile(PlatformFile? file) {
    selectedFile.value = file;
    if (file == null) {
      existingImageUrl.value = '';
      imageError.value = '';
    } else {
      imageError.value = '';
    }
  }

  void setExplanatoryVideoOptionalFile(PlatformFile? file) {
    final hadFileBefore = explanatoryVideoOptionalFile.value != null;
    final hadExistingUrl = existingVideoUrl.value.isNotEmpty;

    explanatoryVideoOptionalFile.value = file;

    if (file == null) {
      if (hadFileBefore) {
        existingVideoUrl.value = '';
        videoRemovedByUser.value = false;
      } else if (hadExistingUrl) {
        existingVideoUrl.value = '';
        videoRemovedByUser.value = true;
      }
    } else {
      existingVideoUrl.value = '';
      videoRemovedByUser.value = false;
    }
  }

  Future<void> createProduct() async {
    isLoading.value = true;
    titleError.value = '';
    costInPointsError.value = '';
    endDateError.value = '';
    imageError.value = '';
    descriptionError.value = '';
    bool hasError = false;

    if (titleController.text.isEmpty) {
      titleError.value = 'titleIsRequired'.tr;
      hasError = true;
    }

    if (descriptionController.text.trim().isNotEmpty) {
      final words =
          descriptionController.text.trim().split(RegExp(r'\s+')).length;
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }

    if (costInPointsController.text.isEmpty) {
      costInPointsError.value = 'costIsRequired'.tr;
      hasError = true;
    }

    if (endDateController.text.isEmpty) {
      endDateError.value = 'validityIsRequired'.tr;
      hasError = true;
    }

    if (selectedFile.value == null) {
      imageError.value = 'imageRequired'.tr;
      hasError = true;
    }

    if (hasError) {
      isLoading.value = false;
      return;
    }

    if (selectedFile.value == null) {
      isLoading.value = false;
      CommonSnackbar.error('fileIsRequired'.tr);
      return;
    }

    final date = DateFormat('dd-MM-yyyy').parse(endDateController.text);
    try {
      final result = await PointStoreRepo.createProduct(
        titleController.text,
        descriptionController.text,
        date,
        int.parse(costInPointsController.text),
        selectedFile.value!.bytes!,
        selectedFile.value!.name,
        explanatoryVideoOptionalFile.value?.bytes,
        explanatoryVideoOptionalFile.value?.name,
      );
      if (result.isSuccess) {
        Get.back();
        isLoading.value = false;
        fetchProducts();
        CommonSnackbar.success('productCreatedSuccessfully'.tr);
      } else {
        isLoading.value = false;
        CommonSnackbar.error('productCreationFailed'.tr);
      }
    } catch (e) {
      isLoading.value = false;
      CommonSnackbar.error(e.toString());
    }
    isLoading.value = false;
  }

  void increment() => count.value++;
}
