import 'package:flutter/material.dart';

class CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  const CustomCalendarDialog({super.key, required this.initialDate});

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime _selectedDate;
  late DateTime _viewDate;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_viewDate.year, _viewDate.month, 1);
    int prevDaysCount = firstDayOfMonth.weekday - 1; 
    final startDay = firstDayOfMonth.subtract(Duration(days: prevDaysCount));
    return List.generate(42, (index) => startDay.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateCalendarDays();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF323236), 
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_months[_viewDate.month - 1]} ${_viewDate.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Color(0xFF007AFF), size: 28),
                        onPressed: () {
                          setState(() {
                            _viewDate = DateTime(_viewDate.year, _viewDate.month - 1, 1);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Color(0xFF007AFF), size: 28),
                        onPressed: () {
                          setState(() {
                            _viewDate = DateTime(_viewDate.year, _viewDate.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekDays.map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth = day.month == _viewDate.month;
                  final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                  final isToday = day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;

                  BoxDecoration? decoration;
                  TextStyle textStyle = TextStyle(
                    color: isCurrentMonth ? Colors.white : Colors.white24,
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                  );

                  if (isSelected) {
                    decoration = const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    );
                    textStyle = const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
                    );
                  } else if (isToday) {
                    decoration = BoxDecoration(
                      border: Border.all(color: const Color(0xFF007AFF), width: 1.5),
                      shape: BoxShape.circle,
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: decoration,
                      alignment: Alignment.center,
                      child: Text(day.day.toString(), style: textStyle),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.5, color: Colors.white10),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}