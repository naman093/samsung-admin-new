import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/product_order_model.dart';
import 'package:universal_html/html.dart' as html;
import '../../../repository/prod_order_repo.dart';

class ProdOrdersController extends GetxController {
  final ProdOrderRepo _prodOrderRepo = Get.find<ProdOrderRepo>();

  final productId = ''.obs;
  final isLoading = false.obs;
  final orders = <ProductOrderModel>[].obs;

  RxString startDate = ''.obs;
  RxString endDate = ''.obs;

  @override
  void onInit() {
    super.onInit();

    ever(productId, (_) {
      debugPrint('ProductId changed to: ${productId.value}');
      if (productId.value.isNotEmpty) {
        fetchOrders();
      }
    });

    if (Get.parameters.containsKey('id')) {
      final id = Get.parameters['id'];
      debugPrint('Found ID in parameters: $id');
      if (id != null && id.isNotEmpty) {
        productId.value = id;
      }
    } else if (Get.arguments != null && Get.arguments is String) {
      final id = Get.arguments as String;
      debugPrint('Found ID in arguments: $id');
      productId.value = id;
    } else {
      debugPrint('No ID found in parameters or arguments');
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (productId.value.isNotEmpty || productId.value != Get.parameters['id']) {
      fetchOrders();
    }
  }

  Future<void> fetchOrders({
    String? startDate,
    String? endDate,
    String? searchTerm,
    String? shortBy,
  }) async {
    debugPrint('Fetching orders for: ${productId.value}');
    isLoading.value = true;
    final result = await _prodOrderRepo.fetchOrdersByProductId(
      productId.value,
      startDate,
      endDate,
      searchTerm,
      shortBy,
    );
    isLoading.value = false;

    switch (result) {
      case Success(data: final ordersList):
        orders.assignAll(ordersList);
      case Failure(message: final error):
        CommonSnackbar.error(error);
    }
  }

  void downloadCsv() {
    List<List<dynamic>> rows = [];
    rows.add([
      'Name',
      'Order Date',
      'City',
      'Address',
      'Zip Code',
      'Mobile Number',
    ]);

    for (var order in orders) {
      final user = order.user;
      rows.add([
        user?.fullName ?? user?.phoneNumber ?? '-',
        DateFormat('dd/MM/yyyy').format(order.orderedAt),
        order.shippingCity ?? '-',
        order.shippingAddress ?? '-',
        order.shippingZip ?? '-',
        order.shippingPhone ?? '-',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'orders.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      debugPrint('CSV Export: \n$csv');
      Get.snackbar(
        'Info',
        'CSV export is only supported on Web currently. Data printed to console.',
      );
    }
  }
}
