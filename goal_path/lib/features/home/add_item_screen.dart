import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/widgets/app_button.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/constants/app_strings.dart';
import 'package:goal_path/core/widgets/app_text_field.dart';
import 'package:goal_path/core/widgets/app_calendar_dialog.dart';
// TODO: когда добавим Provider — заменим setState на notifyListeners()

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _commentController = TextEditingController();
  final _nameFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _commentFocus = FocusNode();
  
  Uint8List? _selectedImageBytes;
  File? _selectedImage;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isUnpurchased = true;
  bool _isCategoryOpen = false;

  final _picker = ImagePicker();

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedCategory != null &&
      _priceController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_rebuild);
    _priceController.addListener(_rebuild);
    _commentFocus.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _commentController.dispose();
    _nameFocus.dispose();
    _priceFocus.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _onAddPhotoTap() async {
    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text(
          AppStrings.photoPermissionTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
            height: 22/17,
          ),
        ),
        content: const Text(
          AppStrings.photoPermissionDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: AppSizes.fontLabel,
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.08
          ),
          ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              AppStrings.selectPhotos,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff007AFF),
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
                height: 22/17,
              ),
            ),
            onPressed: () { Navigator.pop(ctx); _pickImage(); },
          ),
          CupertinoDialogAction(
            child: const Text(
              AppStrings.allowAllPhotos,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff007AFF),
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
                height: 22/17,
              ),
            ),
            onPressed: () { Navigator.pop(ctx); _pickImage(); },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text(
              AppStrings.dontAllow,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff007AFF),
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
                height: 22/17,
              ),
              
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Future<void> _onPhotoTapWhenDenied() async {
    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text(
          AppStrings.accessDeniedTitle,
          style: TextStyle(
            color: Colors.black,
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
                height: 22/17,
          ),
        ),
        content: const Text(
          AppStrings.accessDeniedDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.08,
            height: 22/17,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(
                color: Color(0xff007AFF),
                fontWeight: FontWeight.w400,
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.41,
                height: 22 / 17,
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text(
              AppStrings.settings,
              style: TextStyle(
                color: Color(0xff007AFF),
                fontWeight: FontWeight.w600,
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.41,
                height: 22 / 17,
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: открыть настройки (app_settings пакет)
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null){
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _selectedImageBytes = bytes);
      } else {
        setState(() => _selectedImage = File(picked.path));
      }
    }
  }

  // ИЗМЕНЕНО: открываем диалог по центру экрана — как в Figma
  Future<void> _onDateTap() async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierColor: Colors.black54, // затемнение фона
      builder: (ctx) => AppCalendarDialog(
        initialDate: _selectedDate,
        today: DateTime.now(),
        onDateSelected: (date) => setState(() => _selectedDate = date),
      ),
    );
  }

  void _onAddTap() {
    if (!_isFormValid) return;
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'price': _priceController.text.trim(),
      'date': DateFormat('dd.MM.yyyy').format(_selectedDate),
      'comment': _commentController.text.trim(),
      'purchased': !_isUnpurchased,
      'image': kIsWeb ? _selectedImageBytes : _selectedImage?.path,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spaceM),
                _buildPhotoPicker(),
                const SizedBox(height: AppSizes.spaceXS),

                _buildLabel(AppStrings.purchaseName),
                const SizedBox(height: 4),
                AppTextField(controller: _nameController, focusNode: _nameFocus),
                const SizedBox(height: AppSizes.spaceM),

                _buildLabel(AppStrings.category),
                const SizedBox(height: 4),
                _buildCategoryDropdown(),
                const SizedBox(height: AppSizes.spaceM),

                _buildLabel(AppStrings.purchasePrice),
                const SizedBox(height: 4),
                AppTextField(
                  controller: _priceController,
                  focusNode: _priceFocus,
                  prefixText: '\$',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text.replaceAll(' ', '');
                      if (text.isEmpty) return newValue;

                      final buffer = StringBuffer();
                      for (int i = 0; i < text.length; i++) {
                        if (i !=0 && (text.length - i) % 3 == 0) {
                          buffer.write(' ');
                        }
                        buffer.write(text[i]);
                      }

                      final formatted = buffer.toString();
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceM),

                _buildLabel(AppStrings.dateAddedToChecklist),
                const SizedBox(height: 4),
                _buildDateField(),
                const SizedBox(height: AppSizes.spaceS),

                _buildLabel(AppStrings.commentOptional),
                const SizedBox(height: 4),
                AppTextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  isMultiline: true,
                ),
                const SizedBox(height: AppSizes.spaceM),

                _buildCheckboxRow(),
                const SizedBox(height: AppSizes.spaceXL),

                AppButton(
                  text: AppStrings.add,
                  onPressed: _isFormValid ? _onAddTap : null,
                ),
                const SizedBox(height: AppSizes.spaceXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textOnDark, size: AppSizes.iconM),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        AppStrings.addItem,
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: AppSizes.fontAppar,
          fontWeight: FontWeight.w500,
          color: AppColors.textOnDark,
          letterSpacing: 14 * 0.02,
        ),
      ),
      elevation: 0,
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: GestureDetector(
        onTap: (kIsWeb ? _selectedImageBytes == null : _selectedImage == null)
          ? _onAddPhotoTap
          : _onPhotoTapWhenDenied,
          child:Container(
            width: AppSizes.photoSize,
            height: AppSizes.photoSize,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.photoRadius),
              border: Border.all(color: Color(0xFFBBBBBB),),
            ),
          child: (kIsWeb ? _selectedImageBytes != null : _selectedImage != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.photoRadius),
                  child: kIsWeb
                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                  : Image.file(_selectedImage!, fit: BoxFit.cover,),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera,
                        color: AppColors.textOnDark, size: 32),
                    SizedBox(height: AppSizes.spaceS),
                    Text(AppStrings.addPhoto,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: AppSizes.fontButton,
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 14 * 0.02,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: AppSizes.fontLabel,
        color: AppColors.textOnDark,
        letterSpacing: 14 * 0.02,
        fontWeight: FontWeight.w100,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isCategoryOpen = !_isCategoryOpen),
          child: Container(
            height: AppSizes.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: _isCategoryOpen
                  ? const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusM))
                  : BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: Color(0xffBBBBBB),
                width: AppSizes.fieldBorderWidth,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCategory ?? '',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: AppSizes.fontButton,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
                Icon(
                  _isCategoryOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textOnDark,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
        if (_isCategoryOpen)
          Container(
            height: 392,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppSizes.radiusM)),
              border: Border.all(
                  color: Color(0xffBBBBBB), width: AppSizes.fieldBorderWidth),
            ),
            child: ListView.builder(
              // shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: AppStrings.categories.length,
              itemBuilder: (ctx, i) {
                final cat = AppStrings.categories[i];
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () => setState(() {
                    _selectedCategory = cat;
                    _isCategoryOpen = false;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingM),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(cat,
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: AppSizes.fontButton,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 14 * 0.02,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textOnDark,
                              )),
                        ),
                        _buildSquareCheckbox(isSelected),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Поле даты — тап открывает диалог по центру
  Widget _buildDateField() {
    return GestureDetector(
      onTap: _onDateTap,
      child: Container(
        height: AppSizes.fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: AppColors.grey, width: AppSizes.fieldBorderWidth),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd.MM.yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: AppSizes.fontButton,
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 14 * 0.02,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary, 
              size: AppSizes.iconM,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow() {
    return Row(
      children: [
        _buildCheckboxItem(
          label: AppStrings.unpurchased,
          isChecked: _isUnpurchased,
          checkedColor: const Color(0xFFD33636),
          onTap: () => setState(() => _isUnpurchased = true),
        ),
        const SizedBox(width: AppSizes.fieldHeight),
        _buildCheckboxItem(
          label: AppStrings.purchased,
          isChecked: !_isUnpurchased,
          checkedColor: Color(0xff12B28C),
          onTap: () => setState(() => _isUnpurchased = false),
        ),
      ],
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool isChecked,
    required Color checkedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: AppSizes.checkboxSize,
            height: AppSizes.checkboxSize,
            decoration: BoxDecoration(
              color: isChecked ? checkedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isChecked ? checkedColor : Color(0xffAEAEB2),
                width: 1.5,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 21)
                : null,
          ),
          const SizedBox(width: AppSizes.spaceS),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: AppSizes.fontButton,
              fontWeight: FontWeight.w400,
              letterSpacing: 14 * 0.02,
              color: isChecked ? AppColors.textOnDark : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareCheckbox(bool isSelected) {
    return Container(
      width: AppSizes.checkboxSize,
      height: AppSizes.checkboxSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 14)
          : null,
    );
  }
}
