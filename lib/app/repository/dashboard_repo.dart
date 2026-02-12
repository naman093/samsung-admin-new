import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/dashboard_counts_model.dart';

class DashBoardRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Result<DashboardCounts>> getCounts() async {
    try {
      // 1. Get Events Count
      final eventsRes = await supabase
          .from('events')
          .select('id')
          .or('deleted_at.is.null');
      final eventsCount = (eventsRes as List).length;

      // 2. Get Users Count (excluding admins)
      final usersRes = await supabase
          .from('users')
          .select('id')
          .neq('role', 'admin')
          .or('deleted_at.is.null');
      final usersCount = (usersRes as List).length;

      // 3. Get Academy Content (Lessons) Count
      // Using the view v_academy_content_full as suggested by the provided snippets
      final lessonsRes = await supabase
          .from('v_academy_content_full')
          .select('academy_content_id');
      final lessonsCount = (lessonsRes as List).length;

      return Success(
        DashboardCounts(
          events: eventsCount,
          users: usersCount,
          lessons: lessonsCount,
          tasks: 0,
        ),
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, List<DateTime>>>> getChartData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = startDate.toIso8601String();
      final end = endDate.toIso8601String();

      // 1. Fetch Posts (Content table where type is feed)
      final postsRes = await supabase
          .from('content')
          .select('created_at')
          .eq('content_type', 'feed')
          .or('deleted_at.is.null')
          .gte('created_at', start)
          .lte('created_at', end);

      // 2. Fetch Academy Content (distinguish between Lessons, Tasks, Zoom Workshops)
      // Using the view to be safe with column names
      final academyRes = await supabase
          .from('v_academy_content_full')
          .select('created_at, file_type')
          .gte('created_at', start)
          .lte('created_at', end);

      // 3. Fetch Events
      final eventsRes = await supabase
          .from('events')
          .select('created_at')
          .or('deleted_at.is.null')
          .gte('created_at', start)
          .lte('created_at', end);

      final posts = (postsRes as List)
          .map((e) => DateTime.parse(e['created_at']))
          .toList();

      final lessons = <DateTime>[];
      final tasks = <DateTime>[];
      final zoom = <DateTime>[];

      for (var item in (academyRes as List)) {
        final date = DateTime.parse(item['created_at']);
        final type = item['file_type'] as String?;
        if (type == 'video' || type == 'reel') {
          lessons.add(date);
        } else if (type == 'assignment') {
          tasks.add(date);
        } else if (type == 'zoom_workshop') {
          zoom.add(date);
        }
      }

      // Events can also be categorized or used for zoom workshops if academy_content doesn't cover them.
      // But according to the chart, we have Zoom Workshops.

      return Success({
        'posts': posts,
        'lessons': lessons,
        'tasks': tasks,
        'zoom': zoom,
        'events': (eventsRes as List)
            .map((e) => DateTime.parse(e['created_at']))
            .toList(),
      });
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
