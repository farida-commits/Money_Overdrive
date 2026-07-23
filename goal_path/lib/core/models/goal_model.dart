import 'package:hive/hive.dart';

part 'goal_model.g.dart'; 

@HiveType(typeId: 0) 
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String deadline; 

  @HiveField(4)
  final DateTime deadlineDate; 

  @HiveField(5)
  final DateTime createdAt; 

  @HiveField(6)
  final String? comment;

  @HiveField(7)
  final bool isCompleted;

  GoalModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.deadline,
    required this.deadlineDate,
    required this.createdAt,
    this.comment,
    this.isCompleted = false,
  });

  double get progress {
    if (isCompleted) return 1.0;
    
    final now = DateTime.now();
    if (now.isAfter(deadlineDate)) return 1.0;
    
    var startPoint = createdAt;
    if (deadlineDate.difference(startPoint).inDays < 30) {
      startPoint = deadlineDate.subtract(const Duration(days: 30));
    }
    
    final total = deadlineDate.difference(startPoint).inMinutes;
    final passed = now.difference(startPoint).inMinutes;

    if (total <= 0) return 0.2;
    return (passed / total).clamp(0.15, 1.0);
  }

  bool get isUrgent {
    if (isCompleted) return false;
    final now = DateTime.now();
    final difference = deadlineDate.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }
}