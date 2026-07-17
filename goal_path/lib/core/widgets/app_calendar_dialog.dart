import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
// ─────────────────────────────────────────────
// Диалог календаря — появляется по центру экрана
// Фон чуть светлее: 0xFF3A3D45
// Внизу: разделитель + Done
// ─────────────────────────────────────────────
class AppCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime today;
  final ValueChanged<DateTime> onDateSelected;

  const AppCalendarDialog({
    super.key,
    required this.initialDate,
    required this.today,
    required this.onDateSelected,
  });

  @override
  State<AppCalendarDialog> createState() => _AppCalendarDialogState();
}

class _AppCalendarDialogState extends State<AppCalendarDialog> {
  late DateTime _focusedMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selected = widget.initialDate;
  }

  void _prev() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _next() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday - 1;
    final rows = ((startOffset + lastDay.day) / 7).ceil();

    return Dialog(
      // ИЗМЕНЕНО: фон диалога чуть светлее серый как в Figma
      backgroundColor: const Color.fromARGB(255, 70, 71, 72),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.33)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок + стрелки
            Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _prev,
                  child: const Icon(Icons.chevron_left, color: AppColors.primary, size: 34,),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _next,
                  child: const Icon(Icons.chevron_right, color: AppColors.primary, size: 34,),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // MON TUE WED THU FRI SAT SUN
            Row(
              children: ['MON','TUE','WED','THU','FRI','SAT','SUN']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4DFFFFFF),
                              )),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),

            // Сетка дней
            ...List.generate(rows, (row) => Row(
              children: List.generate(7, (col) {
                final idx = row * 7 + col - startOffset + 1;

                // Пустые ячейки соседних месяцев
                if (idx < 1 || idx > lastDay.day) {
                  String label = '';
                  if (idx < 1) {
                    label = '${DateTime(_focusedMonth.year, _focusedMonth.month, 0).day + idx}';
                  } else {
                    label = '${idx - lastDay.day}';
                  }
                  return Expanded(
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Text(
                          label,
                            style: const TextStyle(
                                fontSize: 20, 
                                color: AppColors.grey
                              ),
                          ),
                      ),
                    ),
                  );
                }

                final date = DateTime(_focusedMonth.year, _focusedMonth.month, idx);
                final isToday = _same(date, _selected);
                final isSelected = _same(date, widget.today);
                final isSelectedNotToday = isSelected && !isToday;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selected = date);
                      widget.onDateSelected(date);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Сегодня — синяя заливка
                          color: isToday ? AppColors.primary : Colors.transparent,
                          // Другая выбранная — синяя обводка
                          border: isSelectedNotToday
                              ? Border.all(color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$idx',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 20,
                              color: isToday ? Colors.white : AppColors.textOnDark,
                              fontWeight: (isToday || isSelected)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            )),

            const SizedBox(height: 8),

            // Разделитель + Done
            const Divider(color: AppColors.grey, height: 1, thickness: 0.5),
            SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  AppStrings.done,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 17,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 14 * 0.02
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