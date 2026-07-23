import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/constants/app_strings.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/providers/purchases_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Purchased/Planned toggle
  bool _isPurchased = true;
  // See all / Hide
  bool _showAll = false;

  // Категориялар боюнча түстөр
  static const _categoryColors = [
    Color(0xFF4132C7), // синий
    Color(0xFFC78D32), // оранжевый
    Color(0xFF32C7BA), // голубой
    Color(0xFFC732BD), // розовый
    Color(0xFFEDED0D), // зеленый
    Color(0xFFEF5350), // красный
    Color(0xFF5C9A3E), // бирюзовый
    Color(0xFF522583), // фиолетовый
  ];

  // Прайс санды алуу
  int _parsePrice(dynamic price) {
    return int.tryParse(
            price?.toString().replaceAll(' ', '') ?? '0') ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final purchases = context.watch<PurchasesProvider>().purchases;

    // Эгер purchases бош болсо — empty state
    if (purchases.isEmpty) return _buildEmptyState();

    // Жалпы сумма
    final totalAmount = purchases.fold<int>(
        0, (sum, item) => sum + _parsePrice(item['price']));

    // Куплено
    final purchasedItems =
        purchases.where((item) => item['purchased'] == true).toList();
    final purchasedAmount = purchasedItems.fold<int>(
        0, (sum, item) => sum + _parsePrice(item['price']));

    // Жок болсо — 0%
    final purchasedPercent =
        totalAmount > 0 ? (purchasedAmount / totalAmount * 100).round() : 0;
    final needMoreAmount = totalAmount - purchasedAmount;
    final needMorePercent = 100 - purchasedPercent;

    // Айлар боюнча чыгым
    final monthlyData = _getMonthlyData(purchases);

    // Категория маалыматтары
    final categoryData = _getCategoryData(
        _isPurchased ? purchasedItems : purchases.where((item) => item['purchased'] != true).toList());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Purchase analytics',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: AppSizes.fontAppar,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnDark,
            letterSpacing: 14 * 0.02,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Жалпы сумма
            _buildTotalSection(totalAmount, purchasedAmount,
                purchasedPercent, needMoreAmount, needMorePercent),

            const SizedBox(height: 24),

            const Text(
              'Expenditure by month',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: AppSizes.fontButton,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnDark,
                letterSpacing: 14 * 0.02,
              ),
            ),
            const SizedBox(height: 1),
            _buildBarChart(monthlyData),

            const SizedBox(height: 24),

            // Donut chart
            _buildDonutChart(categoryData),

            const SizedBox(height: 16),

            // Purchased / Planned toggle
            _buildToggle(),

            const SizedBox(height: 16),

            // Категория тизмеси
            _buildCategoryList(categoryData),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Purchase analytics',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: AppSizes.fontAppar,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnDark,
            letterSpacing: 14 * 0.02,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/diagram.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your purchases and track\nyour expenses to make it easier\nto achieve your goals!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: AppSizes.fontButton,
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
                letterSpacing: 14 * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Жалпы сумма ──────────────────────────
  Widget _buildTotalSection(int total, int purchased, int purchasedPercent,
      int needMore, int needMorePercent) {
    return Column(
      children: [
        // Total
        const Text(
          'Total of all purchases',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${_formatAmount(total)}',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 14 * 0.02,
            color: AppColors.textOnDark,
          ),
        ),
        const SizedBox(height: 12),

        // Purchased + Need more карточкалары
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Purchased',
                '\$${_formatAmount(purchased)} ($purchasedPercent%)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Need more',
                '\$${_formatAmount(needMore)} ($needMorePercent%)',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 12,
                color: Color(0x66FFFFFF),
                letterSpacing: 14 * 0.02,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: AppSizes.fontButton,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnDark,
                letterSpacing: 14 * 0.02,
              )),
        ],
      ),
    );
  }

  // ── Bar chart (Интервалдары бирдей жана Макс 1500 чектөөсү менен) ──
  Widget _buildBarChart(Map<String, int> monthlyData) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  int maxAmount = 0;
  for (final amount in monthlyData.values) {
    if (amount > maxAmount) maxAmount = amount;
  }
  if (maxAmount == 0) maxAmount = 100;
    final maxY = ((maxAmount / 1000).ceil() * 1000).toDouble();
    final step = (maxY / 4).round();
    final yLabels = [
      0,
      step,
      step * 2,
      step * 3,
      step * 4 > maxY ? maxY.toInt() : step * 4,
    ];
  
  
  return Container(
    height: 107,
    color: AppColors.background,
    child: LayoutBuilder(
      builder: (context, constraints) {

        return CustomPaint(
          painter: _BarChartGridPainter(yLabels: yLabels),
          child: Padding(
            // Сол жакта Y белгилери үчүн орун
            padding: const EdgeInsets.only(left: 40, bottom: 4,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {

                final month = months[index];
                final amount = monthlyData[month] ?? 0;
                final chartHeight = constraints.maxHeight - 20;
                final clampedAmount = amount > maxY ? maxY : amount.toDouble();
                final barHeight = (clampedAmount / maxY) * chartHeight;
                
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Баганча - линиянын так үстүндө
                        Tooltip(
                          message: amount > 0
                              ? '$month: \$${_formatAmount(amount)}'
                              : '$month: \$0',
                          preferBelow: false,
                          verticalOffset: 10,
                          child: Container(
                            width: 16,
                            height: barHeight > 0 ? barHeight : 0,
                            decoration: barHeight > 0
                                ? BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary,
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                );
              }).toList(),
            ),
          ),
        );
      },
    ),
  );
}
  
  Widget _leftTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 9,
        color: Color(0x99FFFFFF),
      ),
    ),
  );
}

  Widget _buildDonutChart(List<MapEntry<String, int>> categoryData) {
    final total = categoryData.fold<int>(0, (s, e) => s + e.value);

    return SizedBox(
      height: 299,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 103,
              sections: categoryData.isEmpty
                  ? [
                      PieChartSectionData(
                          color: const Color(0xFF2A2D35),
                          value: 1,
                          title: '',
                          radius: 40
                        ),
                    ]
                  : categoryData.asMap().entries.map((e) {
                      final percent = total > 0
                          ? (e.value.value / total * 100).round()
                          : 0;
                      return PieChartSectionData(
                        color: _categoryColors[e.key % _categoryColors.length],
                        value: e.value.value.toDouble(),
                        title: '',
                        
                        radius: 40,
                      );
                    }).toList(),
            ),
          ),
          Text(
            _isPurchased
                ? 'What was\nthe most spent on'
                : 'What are you\nplanning to buy',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: AppSizes.fontButton,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnDark,
              letterSpacing: 14 * 0.02,
            ),
          ),
        ],
      ),
    );
  }
  // ── Toggle Purchased / Planned ────────────
  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0x33FFFFFF),
          width: 1.5,
        )
      ),
      child: Row(
        children: [
          _toggleItem('Purchased', _isPurchased, () {
            setState(() => _isPurchased = true);
          }),
          _toggleItem('Planned', !_isPurchased, () {
            setState(() => _isPurchased = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: AppSizes.fontBody,
              fontWeight: FontWeight.w500,
              letterSpacing: 14 * 0.02,
              color: isActive ? Colors.white : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // ── Категория тизмеси ─────────────────────
  Widget _buildCategoryList(List<MapEntry<String, int>> categoryData) {
    final total = categoryData.fold<int>(0, (s, e) => s + e.value);

    final allCategories = AppStrings.categories.map((cat) {
      final found = categoryData.firstWhere(
        (e) => e.key == cat,
        orElse: () => MapEntry(cat, 0),
      );
      return found;
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final displayed = _showAll
        ? allCategories
        : allCategories.take(4).toList();

    return Container(
      height: _showAll ? 224.0 : 202.0,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(12),        
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll ? 'Hide' : 'See all',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOnDark,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),

          _showAll
            ?  Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(AppColors.primary),
                    trackColor: WidgetStateProperty.all(const Color(0xFFE8ECF0)),
                    thickness: WidgetStateProperty.all(3.0),
                    radius: const Radius.circular(10),
                  )
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: false,
                  interactive: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 12, bottom: 4,),
                    child: Column(
                      children: displayed.asMap().entries.map((e) {
                        final percent = total > 0
                          ? (e.value.value / total * 100).round()
                          : 0;
                
                          return  Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _categoryColors[e.key % _categoryColors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  e.value.key,
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textOnDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),              
                    ),
                  ),
                ),
              ),
            )
            : Column(
              children: displayed.asMap().entries.map((e) {
                final percent = total > 0
                    ? (e.value.value / total * 100).round()
                    : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _categoryColors[e.key % _categoryColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          e.value.key,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
        ],
      ),
    );
  }

  // ── Helper методдор ───────────────────────
  Map<String, int> _getMonthlyData(List<Map<String, dynamic>> purchases) {
    final Map<String, int> data = {};
    for (final item in purchases) {
      try {
        final date = item['date']?.toString() ?? '';
        final parts = date.split('.');
        if (parts.length == 3) {
          final monthIndex = int.parse(parts[1]) - 1;
          final months = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec'];
          final month = months[monthIndex];
          data[month] = (data[month] ?? 0) + _parsePrice(item['price']);
        }
      } catch (_) {}
    }
    return data;
  }

  List<MapEntry<String, int>> _getCategoryData(
      List<Map<String, dynamic>> items) {
    final Map<String, int> data = {};
    for (final item in items) {
      final cat = item['category']?.toString() ?? 'Other';
      data[cat] = (data[cat] ?? 0) + _parsePrice(item['price']);
    }
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }
}

class _BarChartGridPainter extends CustomPainter {
  final List<int> yLabels;
  
  _BarChartGridPainter({required this.yLabels});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 1;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Сол жактагы отступ (Y белгилери үчүн)
    final leftPadding = 40.0;
    // Астындагы отступ (ай аттары үчүн)
    final bottomPadding = 4.0;
    // Үстүндөгү отступ
    final topPadding = 16.0;
    final verticalLineOverflow = 4.0;
    
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding - topPadding;
    
    // 5 горизонталдык сызык (0, 500, 750, 1000, 1500)
    for (int i = 0; i < yLabels.length; i++) {
      final y = topPadding + (chartHeight / (yLabels.length - 1)) * i;
      
      // Сызыкты тартуу
      canvas.drawLine(
        Offset(leftPadding + 11, y),
        Offset(size.width - 6, y ),
        paint,
      );
      
      // Y огунун тексттерин тартуу
      textPainter.text = TextSpan(
        text: '${yLabels[yLabels.length - 1 - i]}',
        style: const TextStyle(
          color: AppColors.grey,
          fontSize: 9,
          fontFamily: 'SF Pro Display',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width, 
          y - textPainter.height / 2,
        ),
      );
    }
    // 13 вертикалдык сызык (12 ай + 1 жабуучу сызык)
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    
    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + (chartWidth / months.length) * (i + 0.5) ;

      textPainter.text = TextSpan (
        text: months[i],
        style: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 9,
          fontFamily: 'SF Pro Display',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
      Offset(
        x - textPainter.width / 2, 
        topPadding + chartHeight + 14,
      ),
    );
      
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, topPadding + chartHeight + 6),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}