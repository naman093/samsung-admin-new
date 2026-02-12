import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/constant/dashboard_chart_consts.dart';
import 'package:samsung_admin_main_new/app/modules/home/controllers/home_controller.dart';

const Color _postsColor = Color(0xFF60A5FA);
const Color _lessonsColor = Color(0xFFFB7185);
const Color _tasksColor = Color(0xFFFBBF24);
const Color _zoomColor = Color(0xFF3B82F6);

class DashboardBarChart extends GetView<HomeController> {
  const DashboardBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2024),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dashboardContainerBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 7.04),
            blurRadius: 15.73,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          SizedBox(height: 24),
          Expanded(child: _BarChartSection()),
          SizedBox(height: 24),
          _Legend(),
        ],
      ),
    );
  }
}

class _BarChartSection extends GetView<HomeController> {
  const _BarChartSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isChartLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        );
      }

      final data = controller.chartData.toList();
      final labels = controller.chartLabels.toList();
      final groupCount = data.length;
      const double estimatedGroupWidth = 70;

      return LayoutBuilder(
        builder: (context, constraints) {
          final double minWidth = constraints.maxWidth;
          final double requiredWidth = groupCount > 0
              ? groupCount * estimatedGroupWidth
              : minWidth;
          final double chartWidth = requiredWidth < minWidth
              ? minWidth
              : requiredWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: BarChart(_buildChartData(data, labels)),
            ),
          );
        },
      );
    });
  }
}

double _calculateMaxY(List<List<double>> data) {
  if (data.isEmpty) return 10;

  double maxValue = 0;
  for (final month in data) {
    for (final value in month) {
      if (value > maxValue) maxValue = value;
    }
  }

  if (maxValue <= 0) return 10;

  final rounded = ((maxValue / 10).ceil() * 10).toDouble();
  return rounded;
}

BarChartData _buildChartData(List<List<double>> data, List<String> labels) {
  final rawMaxY = _calculateMaxY(data);
  double interval;
  if (rawMaxY <= 50) {
    interval = 10;
  } else if (rawMaxY <= 100) {
    interval = 20;
  } else if (rawMaxY <= 250) {
    interval = 50;
  } else if (rawMaxY <= 500) {
    interval = 100;
  } else if (rawMaxY <= 1000) {
    interval = 200;
  } else {
    interval = (rawMaxY / 10).ceilToDouble();
  }

  final maxY = (rawMaxY / interval).ceil() * interval;
  final maxYWithHeadroom = (maxY * 1.1 / interval).ceil() * interval;

  const BarChartAlignment alignment = BarChartAlignment.spaceBetween;

  return BarChartData(
    alignment: alignment,
    groupsSpace: 5,
    barTouchData: BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => const Color(0xFF111827),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final label = groupIndex < labels.length ? labels[groupIndex] : '';
          final safeIndex = rodIndex.clamp(
            0,
            DashboardChartConsts.tooltipLabelKeys.length - 1,
          );
          final categoryKey = DashboardChartConsts.tooltipLabelKeys[safeIndex];
          final category = categoryKey.tr;
          return BarTooltipItem(
            '$label\n$category: ${rod.toY.toInt()}',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          );
        },
      ),
    ),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      checkToShowHorizontalLine: (value) => value == 0,
      getDrawingHorizontalLine: (value) => FlLine(
        color: const Color(0xFF4B5563),
        strokeWidth: 1,
        dashArray: [4, 4],
      ),
    ),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: interval,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value > maxY) {
              return const SizedBox();
            }
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            if (index < 0 || index >= labels.length) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                labels[index],
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              ),
            );
          },
          reservedSize: 32,
        ),
      ),
    ),
    barGroups: List.generate(data.length, (index) {
      final monthData = data[index];
      return BarChartGroupData(
        x: index,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: monthData[0],
            width: 10,
            borderRadius: BorderRadius.circular(4),
            color: _postsColor,
          ),
          BarChartRodData(
            toY: monthData[1],
            width: 10,
            borderRadius: BorderRadius.circular(4),
            color: _lessonsColor,
          ),
          BarChartRodData(
            toY: monthData[2],
            width: 10,
            borderRadius: BorderRadius.circular(4),
            color: _tasksColor,
          ),
          BarChartRodData(
            toY: monthData[3],
            width: 10,
            borderRadius: BorderRadius.circular(4),
            color: _zoomColor,
          ),
        ],
      );
    }),
    maxY: maxYWithHeadroom,
    minY: 0,
  );
}

class _Header extends GetView<HomeController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(child: _HeaderTexts()),
        Spacer(),
        _RangeSelector(),
      ],
    );
  }
}

class _HeaderTexts extends StatelessWidget {
  const _HeaderTexts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'reviewOfOperations'.tr,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'delaysRegisteringForZoomWorkshopsParticipatingInAcademicAssignmentsAndTheWeeklyPuzzle'
              .tr,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RangeSelector extends GetView<HomeController> {
  const _RangeSelector();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => controller.selectedRange.value = value,
      color: const Color(0xFF111827),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
      ),
      itemBuilder: (context) => [
        _buildRangeMenuItem('weeklyRangeTitle', 'weeklyRange'),
        _buildRangeMenuItem('monthlyRangeTitle', 'monthlyRange'),
        _buildRangeMenuItem('yearlyRangeTitle', 'yearlyRange'),
      ],
      child: const _SelectedRangeChip(),
    );
  }

  PopupMenuItem<String> _buildRangeMenuItem(String valueKey, String labelKey) {
    return PopupMenuItem<String>(
      value: valueKey,
      child: Text(
        labelKey.tr,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _SelectedRangeChip extends GetView<HomeController> {
  const _SelectedRangeChip();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 39, sigmaY: 39),
        child: Container(
          width: 186,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2024),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  controller.selectedRange.value.tr,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'samsungsharpsans',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12,
                    height: 22 / 12,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _LegendItem(color: _postsColor, label: 'totalPosts'.tr),
        _LegendItem(color: _lessonsColor, label: 'totalLessons'.tr),
        _LegendItem(color: _tasksColor, label: 'totalTasks'.tr),
        _LegendItem(color: _zoomColor, label: 'zoomWorkshops'.tr),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}
