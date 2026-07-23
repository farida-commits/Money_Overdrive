import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'add_goal_screen.dart';
import 'package:goal_path/core/models/goal_model.dart';
import 'package:goal_path/core/widgets/goals_segment.dart';
import 'package:goal_path/core/widgets/goals_card.dart';
import 'edit_goal_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}



class _GoalsScreenState extends State<GoalsScreen> {
  bool _isActiveSelected = true;

  final Box<GoalModel> _goalsBox = Hive.box<GoalModel>('goals_box');

  void _markGoalAsCompleted(GoalModel goal) {
   
    final completedGoal = GoalModel(
      id: goal.id,
      name: goal.name,
      amount: goal.amount,
      deadline: goal.deadline,
      deadlineDate: goal.deadlineDate,
      createdAt: goal.createdAt,
      comment: goal.comment,
      isCompleted: true,
    );
    _goalsBox.put(completedGoal.id, completedGoal);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _goalsBox.listenable(),
      builder: (context, Box<GoalModel> box, _) {
      
        final allGoals = box.values.toList();

        final filteredGoals = _isActiveSelected
            ? allGoals.where((g) => !g.isCompleted).toList()
            : allGoals.where((g) => g.isCompleted).toList();

        return Scaffold(
          backgroundColor:AppColors.background,
          appBar: AppBar(
            backgroundColor:AppColors.background,
            elevation: 0,
            title: const Text(
              'My goals',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
          body: Column(
            children: [
              if (allGoals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: GoalsSegment(
                  isActiveSelected: _isActiveSelected,
                  onSegmentChanged: (value) {
                    setState(() {
                      _isActiveSelected = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredGoals.isEmpty
                    ? (_isActiveSelected
                          ? _buildActiveEmptyState()
                          : _buildCompletedEmptyState())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredGoals.length,
                        itemBuilder: (context, index) {
                          
                          final currentGoal = filteredGoals[index];

                          return GestureDetector(
                            
                            onDoubleTap: () {
                              _markGoalAsCompleted(currentGoal);
                            },
                            child: GoalsCard(
                              goal: currentGoal,
                              onTap: () async {
                                
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditGoalScreen(goal: currentGoal),
                                  ),
                                );

                                if (result != null &&
                                    result is Map<String, dynamic>) {
                                  if (result['action'] == 'update') {
                                    final updatedGoal =
                                        result['goal'] as GoalModel;
                                    
                                    _goalsBox.put(updatedGoal.id, updatedGoal);
                                  } else if (result['action'] == 'delete') {
                                    final idToDelete = result['id'] as String;
                                    // Удаляем из Hive
                                    _goalsBox.delete(idToDelete);
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),

              if (_isActiveSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddGoalScreen(),
                          ),
                        );

                        if (result != null && result is GoalModel) {
                         
                          _goalsBox.put(result.id, result);
                        }
                      },
                      child: const Text(
                        '+ Set goal',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/2.json',
            width: 220,
            height: 220,
            repeat: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'This is where your goals\nwill be displayed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              color: AppColors.grey,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/2goals.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          
          ),
          const SizedBox(height: 24),
          const Text(
            "There's nothing here yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              color: Color(0xFF626670),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}