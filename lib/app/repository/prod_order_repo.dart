import 'package:flutter/foundation.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/product_order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdOrderRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Result<List<ProductOrderModel>>> fetchOrdersByProductId(
    String productId,
    String? startDate,
    String? endDate,
    String? searchTerm,
    String? shortBy,
  ) async {
    String toIso(String date) {
      final parts = date.split('-');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      ).toIso8601String();
    }

    debugPrint('called:');
    try {
      var query = supabase
          .from('store_orders')
          .select('*, users(*)')
          .eq('product_id', productId)
          .isFilter('deleted_at', null);

      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        query = query
            .gte('ordered_at', toIso(startDate))
            .lte('ordered_at', toIso(endDate));
      }

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or(
          'shipping_address.ilike.%$searchTerm%,shipping_city.ilike.%$searchTerm%,shipping_zip.ilike.%$searchTerm%,shipping_phone.ilike.%$searchTerm%',
        );
      }

      final response = await query.order('ordered_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final orders = data.map((json) {
        debugPrint('Repo Raw JSON: $json');
        return ProductOrderModel.fromJson(json);
      }).toList();

      return Success(orders);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
