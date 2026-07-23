import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/models/goal_model.dart';
import 'package:goal_path/core/widgets/custom_calendar_dialog.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  
  DateTime? _selectedDate;
  String _formattedDeadline = '';
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final bool valid = _nameController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty &&
        _selectedDate != null;
    
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomCalendarDialog(initialDate: _selectedDate ?? DateTime.now());
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
      _validateForm();
    }
  }

  void _saveGoal() {
    final newGoal = GoalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
      deadline: _formattedDeadline,
      deadlineDate: _selectedDate!,
      createdAt: DateTime.now(),
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      isCompleted: false,
    );

    Navigator.pop(context, newGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set goal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Display',
          ),
        ),
        centerTitle: true,
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
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isFormValid ? _saveGoal : null, 
                  child: const Text(
                    'Set',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Display',
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white,width: 0.6),
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
              Icons.calendar_month_outlined,
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
          color: AppColors.textOnDark,
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
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white,width: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary,),
        ),
      ),
    );
  }
}