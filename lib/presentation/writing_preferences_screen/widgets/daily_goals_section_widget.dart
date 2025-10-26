import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyGoalsSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const DailyGoalsSectionWidget({
    super.key,
    required this.onChanged,
  });

  @override
  State<DailyGoalsSectionWidget> createState() =>
      _DailyGoalsSectionWidgetState();
}

class _DailyGoalsSectionWidgetState extends State<DailyGoalsSectionWidget> {
  int _dailyWritingGoal = 500; // words
  int _weeklyStoriesGoal = 3;
  int _currentStreak = 7;
  int _longestStreak = 15;

  // Sample progress data for the last 7 days
  final List<int> _weeklyProgress = [200, 450, 500, 300, 600, 480, 350];
  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Goals',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.track_changes_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Writing Goal Slider
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Writing Goal',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_dailyWritingGoal words',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Slider(
                    value: _dailyWritingGoal.toDouble(),
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    onChanged: (value) {
                      setState(() {
                        _dailyWritingGoal = value.round();
                      });
                      widget.onChanged();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '100',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '2000',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Stories Goal Slider
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekly Stories Goal',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.secondaryHeaderColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_weeklyStoriesGoal stories',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Slider(
                    value: _weeklyStoriesGoal.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        _weeklyStoriesGoal = value.round();
                      });
                      widget.onChanged();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '10',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Streak Information
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange.shade700,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '$_currentStreak',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        Text(
                          'Current Streak',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade100, Colors.green.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.green.shade700,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '$_longestStreak',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          'Best Streak',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Progress Visualization
            Text(
              'Weekly Progress',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 2.h),

            SizedBox(
              height: 20.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _dailyWritingGoal.toDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${_weekDays[group.x]}\n${rod.toY.round()} words',
                          GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= _weekDays.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                              _weekDays[value.toInt()],
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 8.w,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _weeklyProgress.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    final isGoalMet = value >= _dailyWritingGoal;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          color: isGoalMet
                              ? Colors.green.shade600
                              : theme.primaryColor,
                          width: 4.w,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _dailyWritingGoal / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.dividerColor,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
