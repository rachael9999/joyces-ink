import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

enum MoodDotsViewMode { year, month }

class _DayMood {
  final int count;
  final String iconName;
  final Color color;
  const _DayMood({required this.count, required this.iconName, required this.color});
}

class MoodDotsPage extends StatefulWidget {
  final List<Map<String, dynamic>> entries;
  final DateTime initialDate;

  MoodDotsPage({
    Key? key,
    required this.entries,
    DateTime? initialDate,
  })  : initialDate = initialDate ?? DateTime.now(),
        super(key: key);

  @override
  State<MoodDotsPage> createState() => _MoodDotsPageState();
}

class _MoodDotsPageState extends State<MoodDotsPage> {
  MoodDotsViewMode _mode = MoodDotsViewMode.year;
  late DateTime _current; // anchored to year/month being shown
  double _scale = 1.0;
  double _verticalPhase = 0.0; // drives subtle wave offset on vertical drag
  double _verticalAmp = 0.0; // amplitude scaled with drag distance
  bool _pinchActive = false; // true when multi-touch gesture is active
  double _accumDx = 0.0; // accumulate single-finger horizontal movement

  // Precomputed map: yyyy-mm-dd -> mood icon + color (+ count)
  late final Map<String, _DayMood> _dayMood;

  @override
  void initState() {
    super.initState();
    _current = DateTime(widget.initialDate.year, widget.initialDate.month);
    _dayMood = _computeDailyMood(widget.entries);
  }

  Map<String, _DayMood> _computeDailyMood(List<Map<String, dynamic>> entries) {
    // Group moods per day
    final grouped = <String, List<String>>{};
    for (final e in entries) {
      try {
        final createdRaw = e['created_at']?.toString();
        if (createdRaw == null) continue;
        final dt = DateTime.tryParse(createdRaw);
        if (dt == null) continue;
        final dayKey = _keyForDate(dt);
        final mood = (e['mood'] ?? 'neutral').toString();
        (grouped[dayKey] ??= <String>[]).add(mood);
      } catch (_) {}
    }
    final result = <String, _DayMood>{};
    grouped.forEach((day, moods) {
      if (moods.length > 1) {
        result[day] = const _DayMood(count: 2, iconName: 'star', color: Colors.amber);
      } else {
        final mood = moods.first;
        final mc = _moodToIconAndColor(mood);
        result[day] = _DayMood(count: 1, iconName: mc.$1, color: mc.$2);
      }
    });
    return result;
  }

  String _keyForDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  (String, Color) _moodToIconAndColor(String moodRaw) {
    final mood = moodRaw.toLowerCase();
    // Keep mapping consistent with journal_entry_card_widget
    switch (mood) {
      case 'happy':
        return ('sentiment_very_satisfied', Colors.green);
      case 'confident':
        return ('thumb_up', Colors.indigo);
      case 'sad':
        return ('sentiment_very_dissatisfied', Colors.blue);
      case 'excited':
        return ('sentiment_satisfied', Colors.orange);
      case 'angry':
        return ('sentiment_very_dissatisfied', Colors.red);
      case 'tired':
        return ('bedtime', Colors.deepPurple);
      case 'loved':
        return ('favorite', Colors.pink);
      case 'calm':
        return ('sentiment_neutral', Colors.teal);
      case 'anxious':
        return ('sentiment_dissatisfied', Colors.deepOrange);
      case 'thoughtful':
        return ('psychology', Colors.blueGrey);
      case 'peaceful':
        return ('self_improvement', Colors.cyan);
      case 'neutral':
      default:
        return ('sentiment_neutral', Colors.grey);
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    _scale = 1.0;
    _pinchActive = false;
    _accumDx = 0.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    // If 2+ pointers => pinch/zoom; else treat as single-finger pan
    if (d.pointerCount >= 2) {
      _pinchActive = true;
      setState(() => _scale = d.scale);
    } else {
      _accumDx += d.focalPointDelta.dx;
      setState(() {
        _verticalPhase += d.focalPointDelta.dy * 0.05; // advance wave
        _verticalAmp = (d.focalPointDelta.dy.abs() * 0.3).clamp(0.0, 6.0);
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_pinchActive) {
      // Snap between modes when pinch gesture ends
      if (_scale > 1.1 && _mode == MoodDotsViewMode.year) {
        setState(() {
          _mode = MoodDotsViewMode.month;
          _scale = 1.0;
        });
      } else if (_scale < 0.9 && _mode == MoodDotsViewMode.month) {
        setState(() {
          _mode = MoodDotsViewMode.year;
          _scale = 1.0;
        });
      } else {
        setState(() => _scale = 1.0);
      }
    } else {
      // Single-finger gesture end: evaluate horizontal swipe to pop
      final vx = d.velocity.pixelsPerSecond.dx;
      if (vx > 400 || _accumDx > 80) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    }
    // ease amplitude back
    setState(() => _verticalAmp = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final title = _mode == MoodDotsViewMode.year
        ? '${_current.year} Mood Year'
        : '${_current.year}-${_current.month.toString().padLeft(2, '0')} Mood Month';
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _mode = _mode == MoodDotsViewMode.year
                  ? MoodDotsViewMode.month
                  : MoodDotsViewMode.year;
            }),
            child: Text(
              _mode == MoodDotsViewMode.year ? 'Month' : 'Year',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _mode == MoodDotsViewMode.year
              ? _buildYearView()
              : _buildMonthView(_current.year, _current.month),
        ),
      ),
    );
  }

  Widget _buildYearView() {
    // 12 months as small grids in 3x4
    return Padding(
      key: const ValueKey('year'),
      padding: EdgeInsets.all(4.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 3.w,
          childAspectRatio: 1.0,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          return GestureDetector(
            onTap: () => setState(() {
              _current = DateTime(_current.year, month);
              _mode = MoodDotsViewMode.month;
            }),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(2.w),
              child: Column(
                children: [
                  Text(
                    _monthLabel(month),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Expanded(child: _buildMonthGrid(_current.year, month, mini: true)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthView(int year, int month) {
    return Padding(
      key: const ValueKey('month'),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final prev = DateTime(year, month - 1);
                  setState(() => _current = DateTime(prev.year, prev.month));
                },
                icon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
              Text(
                '${_monthLabel(month)} $year',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                onPressed: () {
                  final next = DateTime(year, month + 1);
                  setState(() => _current = DateTime(next.year, next.month));
                },
                icon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildWeekdayHeader(),
          SizedBox(height: 1.h),
          Expanded(child: _buildMonthGrid(year, month)),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((e) => Expanded(
                child: Center(
                  child: Text(
                    e,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMonthGrid(int year, int month, {bool mini = false}) {
    final firstDay = DateTime(year, month, 1);
    final firstWeekday = (firstDay.weekday % 7); // Monday=1..Sunday=7 -> 1..0
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final itemCount = 42; // 6 rows x 7 columns

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final row = index ~/ 7;
        final col = index % 7;
        final dayNum = index - (firstWeekday == 0 ? 6 : firstWeekday - 1) + 1;
        final inMonth = dayNum >= 1 && dayNum <= daysInMonth;
        final date = inMonth ? DateTime(year, month, dayNum) : null;
    final dm = date == null ? null : _dayMood[_keyForDate(date)];

        // Vertical wave offset
        final wave = math.sin((row * 0.9 + col * 1.1) + _verticalPhase) * _verticalAmp;

        return Transform.translate(
          offset: Offset(0, wave),
          child: Center(
            child: Opacity(
              opacity: inMonth ? 1.0 : 0.15,
              child: dm == null
                  ? Text(
                      '•',
                      style: TextStyle(
                        fontSize: mini ? 10.sp : 16.sp,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: dm.iconName,
                      color: dm.color,
                      size: mini ? 10.sp : 16.sp,
                    ),
            ),
          ),
        );
      },
    );
  }

  String _monthLabel(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
