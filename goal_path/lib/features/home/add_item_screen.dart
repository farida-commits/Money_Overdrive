import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _commentController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isPurchased = false;
  File? _image;

  final List<String> _categories = [
    'Clothing and footwear',
    'Electronics and gadgets',
    'Home and interior',
    'Furniture',
    'Cosmetics and perfumes',
    'Sports and outdoor activities',
    'Goods for children',
    'Automotive goods',
    'Gifts and souvenirs',
    'Travel and leisure',
    'Hobbies and creativity',
    'Health and medicine',
    'Home appliances',
    'Education and courses',
    'Jewelry',
    'Toys and Games',
  ];

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } else if (status.isPermanentlyDenied) {
      _showDeniedDialog();
    }
  }

  void _showDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Access to Photos has been denied',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: const Text(
          'Allow access in Settings. It lets you upload pictures of items you want to buy',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              Container(width: 1, height: 44, color: Colors.grey.shade300),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _selectedCategory != null &&
      _priceController.text.isNotEmpty;

  void _submit() {
    if (!_isFormValid) return;
    Navigator.pop(context, {
      'name': _nameController.text,
      'category': _selectedCategory,
      'price': _priceController.text,
      'date': '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
      'comment': _commentController.text,
      'purchased': _isPurchased,
      'image': _image?.path,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.textOnDark, 
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add item',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: AppColors.textOnDark,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: 14 * 0.02,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textOnDark,
                    ),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/mdi_camera.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.textOnDark,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add photo',
                              style: TextStyle(
                                color: AppColors.textOnDark,
                                fontSize: 20,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Purchase name
            _label('Purchase name'),
            _inputField(_nameController),
            const SizedBox(height: 16),

            // Category
            _label('Category'),
            _dropdownField(),
            const SizedBox(height: 16),

            // Price
            _label('Purchase price'),
            _inputField(_priceController, prefix: '\$',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            // Date
            _label('Date added to checklist'),
            _dateField(),
            const SizedBox(height: 16),

            // Comment
            _label('Comment (Optional)'),
            _inputField(_commentController, maxLines: 4),
            const SizedBox(height: 16),

            // Checkboxes
            Row(
              children: [
                _checkbox('Unpurchased', !_isPurchased, Color(0xFFD33636), () {
                  setState(() => _isPurchased = false);
                }),
                const SizedBox(width: 24),
                _checkbox('Purchased', _isPurchased, Color(0xFF12B28C), () {
                  setState(() => _isPurchased = true);
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? AppColors.primary
                      : AppColors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isFormValid ? _submit : null,
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          color: AppColors.textOnDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 14 * 0.02,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller,
      {String? prefix, TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textOnDark,
        fontFamily: 'SF Pro Display',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 14 * 0.02,
        ),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        prefixText: prefix,
        prefixStyle: const TextStyle(color: AppColors.textOnDark),
        filled: true,
        fillColor: const Color(0xFF1E2530),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0xffBBBBBB),
            width: 1, 
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0xffBBBBBB),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2530),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          hint: const Text(''),
          items: _categories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c,
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontFamily: 'SF Pro Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 14 * 0.02,
                        ),
                      ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2530),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
              style: const TextStyle(
                color: AppColors.textOnDark,
                fontFamily: 'SF Pro Display',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 14 * 0.02,
              ),
            ),
            const Icon(
              CupertinoIcons.calendar,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkbox(
      String label, bool value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? color : AppColors.grey,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(
                  Icons.check, 
                  size: 16, 
                  color: Colors.white,
                )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}