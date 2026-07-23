import 'package:flutter/material.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/models/goal_model.dart';
import 'package:goal_path/core/widgets/custom_calendar_dialog.dart';

class EditGoalScreen extends StatefulWidget {
  final GoalModel goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _commentController;
  
  late DateTime _selectedDate;
  late String _formattedDeadline;
  
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _amountController = TextEditingController(text: widget.goal.amount.toStringAsFixed(0));
    _commentController = TextEditingController(text: widget.goal.comment ?? '');
    
    _selectedDate = widget.goal.deadlineDate;
    _formattedDeadline = widget.goal.deadline;

    _nameController.addListener(_checkChanges);
    _amountController.addListener(_checkChanges);
    _commentController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final double parsedAmount = double.tryParse(_amountController.text.trim()) ?? widget.goal.amount;
    
    final bool changed = _nameController.text.trim() != widget.goal.name ||
        parsedAmount != widget.goal.amount ||
        _commentController.text.trim() != (widget.goal.comment ?? '') ||
        _selectedDate != widget.goal.deadlineDate;

    if (changed != _isChanged) {
      setState(() {
        _isChanged = changed;
      });
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomCalendarDialog(initialDate: _selectedDate);
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year;
      
      setState(() {
        _selectedDate = picked;
        _formattedDeadline = '$day.$month.$year'; 
      });
      _checkChanges();
    }
  }

  void _showCupertinoStyleDialog({
    required String title,
    required String content,
    required String leftButtonText,
    required VoidCallback onLeftPressed,
    required String rightButtonText,
    required VoidCallback onRightPressed,
    bool isRightDestructive = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 270,
              decoration: BoxDecoration(
                color: const Color(0xFFDCDCDC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5, color: Colors.black26),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14)),
                          onTap: onLeftPressed,
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            child: Text(
                              leftButtonText,
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 0.5, height: 44, color: Colors.black26),
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(14)),
                          onTap: onRightPressed,
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            child: Text(
                              rightButtonText,
                              style: TextStyle(
                                color: isRightDestructive ? const Color.fromARGB(255, 30, 148, 250) : const Color(0xFF007AFF),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onBackPressed() {
    if (_isChanged) {
      _showCupertinoStyleDialog(
        title: 'Leave the page',
        content: 'In this case, your goal changes will not be saved',
        leftButtonText: 'Cancel',
        onLeftPressed: () => Navigator.pop(context),
        rightButtonText: 'Leave',
        onRightPressed: () {
          Navigator.pop(context); 
          Navigator.pop(context); 
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showDeleteDialog() {
    _showCupertinoStyleDialog(
      title: 'Delete goal',
      content: 'Do you really want to delete this goal?',
      leftButtonText: 'Cancel',
      onLeftPressed: () => Navigator.pop(context),
      rightButtonText: 'Delete',
      isRightDestructive: true,
      onRightPressed: () {
        Navigator.pop(context); 
        Navigator.pop(context, {'action': 'delete', 'id': widget.goal.id});
      },
    );
  }

  void _confirmSaveGoal() {
    _showCupertinoStyleDialog(
      title: 'Save changes',
      content: 'Do you want to save the changes made to this goal?',
      leftButtonText: 'Cancel',
      onLeftPressed: () => Navigator.pop(context),
      rightButtonText: 'Save',
      onRightPressed: () {
        Navigator.pop(context); 
        
        final updatedGoal = GoalModel(
          id: widget.goal.id, 
          name: _nameController.text.trim(),
          amount: double.tryParse(_amountController.text.trim()) ?? widget.goal.amount,
          deadline: _formattedDeadline,
          deadlineDate: _selectedDate,
          createdAt: widget.goal.createdAt, 
          comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
          isCompleted: widget.goal.isCompleted,
        );

        Navigator.pop(context, {'action': 'update', 'goal': updatedGoal}); 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isChanged, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed(); 
      },
      child: Scaffold(
        backgroundColor:AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _onBackPressed,
          ),
          title: const Text(
            'Edit goal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Display',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
              onPressed: _showDeleteDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Goal name'),
                      _buildTextField(_nameController),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Goal amount'),
                      _buildTextField(
                        
                        _amountController, 
                        keyboardType: TextInputType.number,
                        isAmount: true,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Deadline'),
                      _buildDatePickerTile(),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Comment (Optional)'),
                      _buildTextField(_commentController, maxLines: 3),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.textSecondary,
                      foregroundColor: _isChanged ? Colors.white : Colors.white38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isChanged ? _confirmSaveGoal : null, 
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Display',
                      ),
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

  Widget _buildDatePickerTile() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text(
              _formattedDeadline,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'SF Pro Display',
              ),
            ),
            Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: AppSizes.iconM,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
          fontFamily: 'SF Pro Display',
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isAmount = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: isAmount 
            ? Container(
                width: 32,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: const Text('\$', style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFF1A1D24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 0.6),
        ),
      ),
    );
  }
}