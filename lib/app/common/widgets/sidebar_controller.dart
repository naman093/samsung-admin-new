import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/weekly_riddle_repo.dart';

class SidebarController extends GetxController {
  final WeeklyRiddleRepo _repo = WeeklyRiddleRepo();
  final hasWeeklyRiddle = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    checkRiddleStatus();
  }

  Future<void> checkRiddleStatus() async {
    final result = await _repo.checkRiddleForCurrentWeek();
    hasWeeklyRiddle.value = result;
  }
}
