import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/utils/export_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TransactionRepository _repo = TransactionRepository();
  bool _isLoading = true;
  double _totalRevenue = 0;
  int _transactionCount = 0;
  double _avgOrderValue = 0;
  List<Map<String, dynamic>> _weekData = [];
  List<Map<String, dynamic>> _yearData = [];
  List<Map<String, dynamic>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final summary = await _repo.getTodaySummary();
      final weekData = await _repo.getWeekDailySummary();
      final yearData = await _repo.getYearMonthlySummary();
      final topProducts = await _repo.getTopProducts(5);

      if (mounted) {
        setState(() {
          _totalRevenue = (summary['total'] as num?)?.toDouble() ?? 0.0;
          _transactionCount = (summary['count'] as num?)?.toInt() ?? 0;
          _avgOrderValue = (summary['average'] as num?)?.toDouble() ?? 0.0;
          _weekData = weekData;
          _yearData = yearData;
          _topProducts = topProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'REPORTS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: AppColors.textPrimary),
            color: AppColors.surface,
            onSelected: (value) async {
              final txs = await _repo.getAllTransactions();
              final rows = <List<dynamic>>[];
              rows.add(['ID', 'Date', 'Method', 'Subtotal', 'Tax', 'Discount', 'Total', 'Status']);
              for (final t in txs) {
                rows.add([
                  t.id ?? '',
                  AppConstants.formatDateTime(t.createdAt),
                  t.paymentMethod,
                  t.subtotal,
                  t.taxAmount,
                  t.discountAmount,
                  t.total,
                  t.status,
                ]);
              }
              final fileName = 'Report_${DateTime.now().millisecondsSinceEpoch}';
              
              if (value == 'csv') {
                await ExportHelper.exportToCsv(fileName: fileName, rows: rows);
              } else if (value == 'excel') {
                await ExportHelper.exportToExcel(fileName: fileName, rows: rows);
              } else if (value == 'pdf') {
                final headers = rows.first.map((e) => e.toString()).toList();
                final data = rows.sublist(1);
                await ExportHelper.exportToPdf(fileName: fileName, title: 'Transaction Report', headers: headers, data: data);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'csv',
                child: Text('Export CSV', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
              PopupMenuItem<String>(
                value: 'excel',
                child: Text('Export Excel', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
              PopupMenuItem<String>(
                value: 'pdf',
                child: Text('Export PDF', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODAY'S SUMMARY
                      _SectionTitle(l10n.todayOverview.toUpperCase()),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: l10n.totalRevenue.toUpperCase(),
                              value: AppConstants.formatCurrency(_totalRevenue),
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: l10n.transactionCount.toUpperCase(),
                              value: '$_transactionCount',
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: l10n.avgOrderValue.toUpperCase(),
                              value: AppConstants.formatCurrency(_avgOrderValue),
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
    
                      // WEEKLY CHART
                      _SectionTitle(l10n.thisWeek.toUpperCase()),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0),
                          ],
                        ),
                        child: _weekData.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.noData,
                                  style: GoogleFonts.inter(
                                      color: AppColors.textSecondary),
                                ),
                              )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMaxY(),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: AppColors.card,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  getTooltipItem: (group, gIndex, rod, rIndex) {
                                    return BarTooltipItem(
                                      AppConstants.formatCurrency(rod.toY),
                                      GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      if (value == meta.max) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        AppConstants
                                            .formatCurrencyCompact(value),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final days = [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun'
                                      ];
                                      final idx = value.toInt();
                                      if (idx >= 0 && idx < days.length) {
                                        return Text(
                                          days[idx],
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: AppColors.border,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: _buildBarGroups(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),

                  // MONTHLY CHART
                  _SectionTitle(l10n.thisMonth.toUpperCase()),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.shadow,
                            offset: Offset(4, 4),
                            blurRadius: 0),
                      ],
                    ),
                    child: _yearData.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noData,
                              style: GoogleFonts.inter(
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMonthMaxY(),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: AppColors.card,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  getTooltipItem: (group, gIndex, rod, rIndex) {
                                    return BarTooltipItem(
                                      AppConstants.formatCurrency(rod.toY),
                                      GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      if (value == meta.max) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        AppConstants
                                            .formatCurrencyCompact(value),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final months = [
                                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                      ];
                                      final idx = value.toInt() - 1;
                                      if (idx >= 0 && idx < months.length) {
                                        return Text(
                                          months[idx],
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: AppColors.border,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: _buildMonthBarGroups(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),

                  // TOP PRODUCTS
                  _SectionTitle(l10n.topProducts.toUpperCase()),
                  const SizedBox(height: 12),
                  if (_topProducts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          l10n.noData,
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_topProducts.length, (index) {
                      final p = _topProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          border:
                              Border.all(color: AppColors.border, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(3, 3),
                                blurRadius: 0),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                border: Border.all(
                                    color: AppColors.shadow, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['productName']?.toString() ?? 'Unknown',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${p['totalQty'] ?? 0} sold',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppConstants.formatCurrency(
                                  (p['totalRevenue'] as num?)
                                          ?.toDouble() ??
                                      0),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }),
    );
  }

  double _getMaxY() {
    if (_weekData.isEmpty) return 100000;
    double max = 0;
    for (final d in _weekData) {
      final val = (d['total'] as num?)?.toDouble() ?? 0.0;
      if (val > max) max = val;
    }
    return max * 1.2;
  }

  List<BarChartGroupData> _buildBarGroups() {
    final Map<int, double> dayTotals = {};
    for (int i = 0; i < 7; i++) {
      dayTotals[i] = 0;
    }

    for (final d in _weekData) {
      final dateVal = d['date'];
      if (dateVal != null) {
        try {
          final DateTime date;
          if (dateVal is DateTime) {
            date = dateVal;
          } else {
            date = DateTime.parse(dateVal.toString());
          }
          final weekday = date.weekday - 1; // 0=Mon
          dayTotals[weekday] =
              (dayTotals[weekday] ?? 0.0) + ((d['total'] as num?)?.toDouble() ?? 0.0);
        } catch (_) {}
      }
    }

    return dayTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: AppColors.primary,
            width: 20,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ],
      );
    }).toList();
  }
  double _getMonthMaxY() {
    if (_yearData.isEmpty) return 100000;
    double max = 0;
    for (final d in _yearData) {
      final val = (d['total'] as num?)?.toDouble() ?? 0.0;
      if (val > max) max = val;
    }
    return max * 1.2;
  }

  List<BarChartGroupData> _buildMonthBarGroups() {
    return _yearData.map((entry) {
      return BarChartGroupData(
        x: entry['month'] as int,
        barRods: [
          BarChartRodData(
            toY: (entry['total'] as num?)?.toDouble() ?? 0.0,
            color: AppColors.success,
            width: 12,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.success, width: 2),
          ),
        ],
      );
    }).toList();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 2,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


