import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/widgets/app_button.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/constants/app_strings.dart';
import 'package:goal_path/core/widgets/app_text_field.dart';
import 'package:goal_path/core/widgets/app_calendar_dialog.dart';

class EditItemScreen extends StatefulWidget {
  final Map<String, dynamic> item; // редактируемый item
  final int itemIndex;             // индекс списокто

  const EditItemScreen({
    super.key,
    required this.item,
    required this.itemIndex,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
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
    // ДОБАВИЛИ: учурдагы маалыматты полелерге жүктөйбүз
    _nameController.text = widget.item['name'] ?? '';
    _priceController.text = widget.item['price'] ?? '';
    _commentController.text = widget.item['comment'] ?? '';
    _selectedCategory = widget.item['category'];
    _isUnpurchased = !(widget.item['purchased'] ?? false);
    try {
      _selectedDate = DateFormat('dd.MM.yyyy').parse(widget.item['date']);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
    // Сүрөт жүктөө
    if (widget.item['image'] != null) {
      if (kIsWeb) {
        _selectedImageBytes = widget.item['image'] as Uint8List?;
      } else {
        _selectedImage = File(widget.item['image']);
      }
    }
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

  // Back тапта алерт
  Future<void> _onBackTap() async {
    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text(
          AppStrings.leavePageTitle,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontTitle,
            letterSpacing: -0.41,
          ),
        ),
        content: const Text(
          AppStrings.leavePageDesc,
          style: TextStyle(
            fontFamily: "SF Pro Text",
            fontWeight: FontWeight.w400,
            fontSize: 13,
            letterSpacing: -0.08,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w400,
                fontSize: AppSizes.fontTitle,
                letterSpacing: -0.41,
                color: Color(0xFF007AFF),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text(
              AppStrings.leave,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontTitle,
                letterSpacing: -0.41,
                color: Color(0xFF007AFF),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Delete тапта алерт
  Future<void> _onDeleteTap() async {
    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text(
          AppStrings.deleteItemTitle,
          style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontTitle,
                letterSpacing: -0.41,
              ),
        ),
        content: const Text(
          AppStrings.deleteItemDesc,
          style: TextStyle(
            fontFamily: "SF Pro Text",
            fontWeight: FontWeight.w400,
            fontSize: 13,
            letterSpacing: -0.08,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w400,
                fontSize: AppSizes.fontTitle,
                letterSpacing: -0.41,
                color: Color(0xFF007AFF),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text(
              AppStrings.delete,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontTitle,
                letterSpacing: -0.41,
                color: Color(0xFF007AFF),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // delete сигналы менен чыгабыз
              Navigator.pop(context, {
                'action': 'delete',
                'index': widget.itemIndex,
              });
            },
          ),
        ],
      ),
    );
  }

  void _onSaveTap() {
    if (!_isFormValid) return;
    Navigator.pop(context, {
      'action': 'save',
      'index': widget.itemIndex,
      'item': {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'price': _priceController.text.trim(),
        'date': DateFormat('dd.MM.yyyy').format(_selectedDate),
        'comment': _commentController.text.trim(),
        'purchased': !_isUnpurchased,
        'image': kIsWeb ? _selectedImageBytes : _selectedImage?.path,
      },
    });
  }

  Future<void> _onAddPhotoTap() async {
    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text(AppStrings.photoPermissionTitle),
        content: const Text(AppStrings.photoPermissionDesc),
        actions: [
          CupertinoDialogAction(
            child: const Text(AppStrings.selectPhotos),
            onPressed: () { Navigator.pop(ctx); _pickImage(); },
          ),
          CupertinoDialogAction(
            child: const Text(AppStrings.allowAllPhotos),
            onPressed: () { Navigator.pop(ctx); _pickImage(); },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text(AppStrings.dontAllow),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _selectedImageBytes = bytes);
      } else {
        setState(() => _selectedImage = File(picked.path));
      }
    }
  }

  Future<void> _onDateTap() async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AppCalendarDialog(
        initialDate: _selectedDate,
        today: DateTime.now(),
        onDateSelected: (date) => setState(() => _selectedDate = date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textOnDark, 
              size: AppSizes.iconM,
            ),
            onPressed: _onBackTap, // алерт чыгарат
          ),
          title: const Text(
            AppStrings.editItem,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: AppSizes.fontAppar,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnDark,
            ),
          ),
          actions: [
            // ДОБАВИЛИ: Delete иконка оң жакта
            GestureDetector(
              onTap: _onDeleteTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE05252),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildPhotoPicker(),
                const SizedBox(height: 8),

                _buildLabel(AppStrings.purchaseName),
                const SizedBox(height: 2),
                AppTextField(controller: _nameController, focusNode: _nameFocus),
                const SizedBox(height: 8),

                _buildLabel(AppStrings.category),
                const SizedBox(height: 2),
                _buildCategoryDropdown(),
                const SizedBox(height: 8),

                _buildLabel(AppStrings.purchasePrice),
                const SizedBox(height: 2),
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
                        if (i != 0 && (text.length - i) % 3 == 0) buffer.write(' ');
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
                const SizedBox(height: 8),

                _buildLabel(AppStrings.dateAddedToChecklist),
                const SizedBox(height: 2),
                _buildDateField(),
                const SizedBox(height: 8),

                _buildLabel(_commentFocus.hasFocus
                    ? AppStrings.addComment
                    : AppStrings.commentOptional),
                const SizedBox(height: 2),
                AppTextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  isMultiline: true,
                ),
                const SizedBox(height: 12),

                _buildCheckboxRow(),
                const SizedBox(height: 12),

                AppButton(
                  text: AppStrings.save,
                  onPressed: _isFormValid ? _onSaveTap : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _onAddPhotoTap,
        child: Container(
          width: AppSizes.photoSize,
          height: AppSizes.photoSize,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.photoRadius),
            border: Border.all(color: const Color(0xFFBBBBBB)),
          ),
          child: (kIsWeb ? _selectedImageBytes != null : _selectedImage != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.photoRadius),
                  child: kIsWeb
                      ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera, color: AppColors.textOnDark, size: 32),
                    SizedBox(height: 8),
                    Text(AppStrings.addPhoto,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: AppSizes.fontButton,
                          color: AppColors.textOnDark,
                        )),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: AppSizes.fontButton,
          color: AppColors.textOnDark,
          letterSpacing: 14 * 0.02,
          fontWeight: FontWeight.w400,
        ));
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
                color: _isCategoryOpen ? AppColors.primary : const Color(0xFFBBBBBB),
                width: AppSizes.fieldBorderWidth,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_selectedCategory ?? '',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: AppSizes.fontButton,
                        color: AppColors.textOnDark,
                      )),
                ),
                Icon(
                  _isCategoryOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textOnDark, size: 32,
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
                  color: AppColors.primary, width: AppSizes.fieldBorderWidth),
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

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _onDateTap,
      child: Container(
        height: AppSizes.fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
              color: const Color(0xFFBBBBBB), width: AppSizes.fieldBorderWidth),
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
                ),
              ),
            ),
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary, size: AppSizes.iconM),
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
          checkedColor: _isUnpurchased
            ? AppColors.primary
            : const Color(0xFFD33636),
          onTap: () => setState(() => _isUnpurchased = true),
        ),
        const SizedBox(width: AppSizes.fieldHeight),
        _buildCheckboxItem(
          label: AppStrings.purchased,
          isChecked: !_isUnpurchased,
          checkedColor: !_isUnpurchased 
            ? AppColors.primary
            : const Color(0xFF12B28C),
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
                color: isChecked ? checkedColor : const Color(0xFFAEAEB2),
                width: 1.5,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: AppSizes.spaceS),
          Text(
            label,
            style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: AppSizes.fontButton,
            fontWeight: FontWeight.w400,
            color: isChecked ? AppColors.textOnDark : AppColors.grey,
          )),
        ],
      ),
    );
  }

  Widget _buildSquareCheckbox(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
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