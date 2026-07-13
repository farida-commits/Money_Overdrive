import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
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
  // ДОБАВИЛИ: Purchased/Planned toggle
  bool _isPurchased = true;
  // ДОБАВИЛИ: See all / Hide
  bool _showAll = false;

  // Категориялар боюнча түстөр
  static const _categoryColors = [
    Color(0xFF4132C7), // синий
    Color(0xFFC732BD), // розовый
    Color(0xFF32C7BA), // голубой
    Color(0xFFC78D32), // оранжевый
    Color(0xFFEDED0D), // зеленый
    Color(0xFFEF5350), // красный
    Color(0xFF522583), // фиолетовый
    Color(0xFF26A69A), // бирюзовый
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

            // Expenditure by month
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
            const SizedBox(height: 12),
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

  // ── Bar chart ─────────────────────────────
  Widget _buildBarChart(Map<String, int> monthlyData) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final maxY = monthlyData.values.isEmpty
        ? 1000.0
        : monthlyData.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          backgroundColor: Colors.transparent,
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0x33FFFFFF),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox();
                  return Text(
                    months[idx],
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 7,
                      color: Color(0x66FFFFFF),
                      letterSpacing: 14 * 0.02,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(12, (i) {
            final month = months[i];
            final value = monthlyData[month] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  color: AppColors.primary,
                  width: 16,
                  // borderRadius: const BorderRadius.vertical(
                  //     top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Donut chart ───────────────────────────
  Widget _buildDonutChart(List<MapEntry<String, int>> categoryData) {
    final total = categoryData.fold<int>(0, (s, e) => s + e.value);

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 80,
              sections: categoryData.isEmpty
                  ? [
                      PieChartSectionData(
                          color: const Color(0xFF2A2D35),
                          value: 1,
                          title: '',
                          radius: 40)
                    ]
                  : categoryData.asMap().entries.map((e) {
                      final percent = total > 0
                          ? (e.value.value / total * 100).round()
                          : 0;
                      return PieChartSectionData(
                        color: _categoryColors[
                            e.key % _categoryColors.length],
                        value: e.value.value.toDouble(),
                        title: '$percent%',
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        radius: 40,
                      );
                    }).toList(),
            ),
          ),
          // Ортодогу текст
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
        color: const Color(0xFF252B35),
        borderRadius: BorderRadius.circular(12),
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
    // See all / Hide
    final displayed = _showAll ? categoryData : categoryData.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252B35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll ? 'Hide' : 'See all',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Тизме
          ...displayed.asMap().entries.map((e) {
            final percent =
                total > 0 ? (e.value.value / total * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _categoryColors[e.key % _categoryColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
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
          }),
        ],
      ),
    );
  }

  // ── Helper методдор ───────────────────────

  // Айлар боюнча сумма
  Map<String, int> _getMonthlyData(List<Map<String, dynamic>> purchases) {
    final Map<String, int> data = {};
    for (final item in purchases) {
      try {
        final date = item['date']?.toString() ?? '';
        // dd.MM.yyyy форматы
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

  // Категория боюнча сумма — сорттолгон
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

  // Сумманы форматтоо: 6373 → "6 373"
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }
}