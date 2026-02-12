import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/services/get_prefs.dart';

class AuthGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  bool get _isLoggedIn => GetPrefs.getBool(GetPrefs.isLoggedIn);

  @override
  RouteSettings? redirect(String? route) {
    if (!_isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class GuestOnlyMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  bool get _isLoggedIn => GetPrefs.getBool(GetPrefs.isLoggedIn);

  @override
  RouteSettings? redirect(String? route) {
    if (_isLoggedIn) {
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}
