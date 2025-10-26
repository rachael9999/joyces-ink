import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ReminderNotificationsSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const ReminderNotificationsSectionWidget({
    super.key,
    required this.onChanged,
  });

  @override
  State<ReminderNotificationsSectionWidget> createState() =>
      _ReminderNotificationsSectionWidgetState();
}

class _ReminderNotificationsSectionWidgetState
    extends State<ReminderNotificationsSectionWidget> {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  String _frequency = 'daily'; // daily, weekdays, custom
  Set<String> _customDays = {
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  };
  String _motivationalMessage = 'Time to create your next story! ✨';

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> _presetMessages = [
    'Time to create your next story! ✨',
    'Your daily writing adventure awaits! 📝',
    'Let\'s capture today\'s moments in words! 🌟',
    'Ready to weave some magic with words? ✍️',
    'Your creativity is calling! 🎨',
    'Time to paint with words! 🖋️',
  ];

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      widget.onChanged();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  Widget _buildFrequencyTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _frequency == value;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? theme.primaryColor : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color:
            isSelected ? theme.primaryColor.withAlpha(13) : Colors.transparent,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _frequency,
        onChanged: (newValue) {
          setState(() {
            _frequency = newValue!;
          });
          widget.onChanged();
        },
        title: Row(
          children: [
            Icon(
              icon,
              size: 4.w,
              color: isSelected
                  ? theme.primaryColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(left: 7.w, top: 0.5.h),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDaysSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _weekDays.map((day) {
            final isSelected = _customDays.contains(day);
            return FilterChip(
              selected: isSelected,
              label: Text(
                day.substring(0, 3),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _customDays.add(day);
                  } else {
                    _customDays.remove(day);
                  }
                });
                widget.onChanged();
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.primaryColor,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? theme.primaryColor : theme.dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

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
                  'Reminder Notifications',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.notifications_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Enable/Disable Notifications
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _notificationsEnabled ? Colors.green : Colors.grey,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Reminders',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _notificationsEnabled
                              ? 'Get reminded to write every day'
                              : 'Notifications are disabled',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ),

            if (_notificationsEnabled) ...[
              SizedBox(height: 3.h),

              // Time Selection
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
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 5.w,
                      color: theme.primaryColor,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder Time',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatTime(_reminderTime),
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _selectTime,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Frequency Selection
              Text(
                'Frequency',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 2.h),

              _buildFrequencyTile(
                value: 'daily',
                title: 'Daily',
                subtitle: 'Every day of the week',
                icon: Icons.today,
              ),

              _buildFrequencyTile(
                value: 'weekdays',
                title: 'Weekdays Only',
                subtitle: 'Monday through Friday',
                icon: Icons.business_center,
              ),

              _buildFrequencyTile(
                value: 'custom',
                title: 'Custom Schedule',
                subtitle: 'Choose specific days',
                icon: Icons.calendar_month,
              ),

              if (_frequency == 'custom') ...[
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildCustomDaysSelector(),
                ),
              ],

              SizedBox(height: 3.h),

              // Motivational Message Customization
              Text(
                'Motivational Message',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 2.h),

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
                    TextFormField(
                      initialValue: _motivationalMessage,
                      decoration: const InputDecoration(
                        hintText: 'Enter your motivational message...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.format_quote),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          _motivationalMessage = value;
                        });
                        widget.onChanged();
                      },
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Or choose a preset:',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _presetMessages.map((message) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _motivationalMessage = message;
                            });
                            widget.onChanged();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: _motivationalMessage == message
                                  ? theme.primaryColor.withAlpha(26)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _motivationalMessage == message
                                    ? theme.primaryColor
                                    : theme.dividerColor,
                              ),
                            ),
                            child: Text(
                              message,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: _motivationalMessage == message
                                    ? theme.primaryColor
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Preview Container
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withAlpha(51),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.smartphone,
                      color: Colors.blue.shade700,
                      size: 8.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            'joycesink',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          Text(
                            _motivationalMessage,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}