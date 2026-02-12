class DashboardChartConsts {
  DashboardChartConsts._();

  /// Month labels used on the x-axis of the dashboard bar chart.
  static const List<String> months = <String>[
    'Jan',
    'Feb',
    'March',
    'April',
    'May',
    'Jun',
    'Jul',
  ];

  /// Default static chart data for the dashboard bar chart.
  ///
  /// Each inner list represents one month and contains values for:
  /// [posts, lessons, tasks, zoom workshops].
  static const List<List<double>> defaultChartData = <List<double>>[
    [110, 650, 520, 700],
    [100, 300, 250, 430],
    [90, 60, 200, 520],
    [190, 260, 210, 320],
    [140, 350, 280, 410],
    [80, 220, 260, 380],
    [250, 150, 300, 400],
  ];

  /// Translation keys (or string IDs) for each bar series used in the chart.
  ///
  /// Indexes correspond to:
  /// 0: totalPosts, 1: totalLessons, 2: totalTasks, 3: zoomWorkshops.
  static const List<String> tooltipLabelKeys = <String>[
    'totalPosts',
    'totalLessons',
    'totalTasks',
    'zoomWorkshops',
  ];
}
