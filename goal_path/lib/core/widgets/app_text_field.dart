import 'package:flutter/material.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:flutter/services.dart'; // для FilteringTextInputFormatter

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? prefixText;       // для "$" в поле цены
  final bool isMultiline;         // для поля комментария
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixText,
    this.isMultiline = false,
    this.keyboardType,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _internalFocus;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    // ДОБАВИЛИ: фокус ноду — тышкы же ички
    _internalFocus = widget.focusNode ?? FocusNode();
    _internalFocus.addListener(() {
      setState(() => _hasFocus = _internalFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    // ДОБАВИЛИ: тышкы focusNode берилсе — dispose кылбайбыз
    if (widget.focusNode == null) _internalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Активный бордер — синий, неактивный — серый (как в Figma)
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      borderSide: const BorderSide(
        color: AppColors.grey,
        width: AppSizes.fieldBorderWidth,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: AppSizes.fieldBorderWidth,
      ),
    );

    return TextField(
      controller: widget.controller,
      focusNode: _internalFocus,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      // Многострочное для комментария, иначе одна строка
      maxLines: widget.isMultiline ? null : 1,
      minLines: widget.isMultiline ? 3 : 1,
      keyboardType: widget.isMultiline
          ? TextInputType.multiline
          : (widget.keyboardType ?? TextInputType.text),
      inputFormatters: widget.inputFormatters,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: AppSizes.fontButton,
        color: AppColors.textOnDark,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixText != null ?
        Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Padding(
            padding: const EdgeInsets.only(left: 16,),
            child: Text(
              '\$',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: AppSizes.fontButton,
                fontWeight: FontWeight.w500,
                letterSpacing: 14 * 0.02,
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ) : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0, 
          minHeight: 0,
        ),
        // prefixStyle: const TextStyle(
        //   fontFamily: 'SF Pro Display',
        //   fontSize: AppSizes.fontButton,
        //   color: AppColors.textOnDark,
        // ),
        hintStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: AppSizes.fontButton,
          color: AppColors.grey,
        ),
        filled: true,
        fillColor: AppColors.background, 
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: 11,
        ),
      ),
    );
  }
}