import 'package:flutter/material.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/models/goal_model.dart';

class GoalsCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onTap;

  const GoalsCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4132C7).withValues(alpha: 0.2), 
          borderRadius: BorderRadius.circular(12), 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      
                      if (goal.isCompleted) ...[
                        Image.asset('assets/images/2.4.png'),
                        const SizedBox(width: 8),
                      ] 
                    
                      else if (goal.isUrgent) ...[
                        const Icon(
                          Icons.error,
                          color: Color(0xFFEF5350),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Wrap(
                          children:[ Text(
                            goal.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),]
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$ ${goal.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
            
            if (goal.isCompleted) ...[

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(
                  color: Colors.white12, 
                  height: 1,
                ),
              ),
              const Center(
                child: Text(
                  'Goal achieved!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ] else ...[
          
              const SizedBox(height: 16),
              SizedBox(
                height: 20,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(0xFFE31919),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: goal.progress,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 245, 219, 219),
                              Color.fromARGB(255, 233, 109, 101),
                              Color(0xFFE31919),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: goal.progress,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  goal.deadline,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}