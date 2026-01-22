import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/web_theme.dart';
import 'package:flutter_pal_app/data/models/payment_record_model.dart';
import 'package:flutter_pal_app/presentation/providers/payment_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/payment/payment_form_dialog.dart';

/// 트레이너 웹 매출 관리 화면
class TrainerRevenueWebScreen extends ConsumerStatefulWidget {
  const TrainerRevenueWebScreen({super.key});

  @override
  ConsumerState<TrainerRevenueWebScreen> createState() =>
      _TrainerRevenueWebScreenState();
}

class _TrainerRevenueWebScreenState
    extends ConsumerState<TrainerRevenueWebScreen> {
  final _numberFormat = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Container(
      color: WebTheme.contentBgColor(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(context, isDark, selectedYear, selectedMonth),
            const SizedBox(height: 24),

            // 매출 요약 카드
            _buildSummaryCards(context, isDark),
            const SizedBox(height: 24),

            // 월별 매출 차트
            _buildRevenueChart(context, isDark, selectedYear),
            const SizedBox(height: 24),

            // 결제 내역 테이블
            _buildPaymentsTable(context, isDark),
          ],
        ),
      ),
    );
  }

  /// 헤더 (제목 + 년/월 선택 + 결제 등록 버튼)
  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    int selectedYear,
    int selectedMonth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '매출 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 4),
            Text(
              '결제 내역을 관리하고 매출을 분석하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          ],
        ),
        Row(
          children: [
            // 연도 선택
            _buildYearDropdown(context, isDark, selectedYear),
            const SizedBox(width: 12),
            // 월 선택
            _buildMonthDropdown(context, isDark, selectedMonth),
            const SizedBox(width: 16),
            // 결제 등록 버튼
            FilledButton.icon(
              onPressed: () => _showPaymentDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('결제 등록'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          ],
        ),
      ],
    );
  }

  /// 연도 드롭다운
  Widget _buildYearDropdown(BuildContext context, bool isDark, int selectedYear) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedYear,
          items: years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text('$year년'),
            );
          }).toList(),
          onChanged: (year) {
            if (year != null) {
              ref.read(selectedYearProvider.notifier).setYear(year);
            }
          },
        ),
      ),
    );
  }

  /// 월 드롭다운
  Widget _buildMonthDropdown(BuildContext context, bool isDark, int selectedMonth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(12, (i) => i + 1).map((month) {
            return DropdownMenuItem(
              value: month,
              child: Text('$month월'),
            );
          }).toList(),
          onChanged: (month) {
            if (month != null) {
              ref.read(selectedMonthProvider.notifier).setMonth(month);
            }
          },
        ),
      ),
    );
  }

  /// 매출 요약 카드들
  Widget _buildSummaryCards(BuildContext context, bool isDark) {
    final summaryAsync = ref.watch(paymentSummaryProvider);
    final statsAsync = ref.watch(paymentStatsProvider);

    return summaryAsync.when(
      loading: () => _buildSummaryCardsSkeleton(isDark),
      error: (e, _) => _buildErrorCard(e, isDark),
      data: (summary) {
        return statsAsync.when(
          loading: () => _buildSummaryCardsSkeleton(isDark),
          error: (e, _) => _buildErrorCard(e, isDark),
          data: (stats) {
            return Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: '이번 달 매출',
                    value: '${_numberFormat.format(summary.monthlyRevenue)}원',
                    icon: Icons.payments_outlined,
                    color: AppTheme.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: '결제 회원 수',
                    value: '${summary.memberCount}명',
                    icon: Icons.people_outline,
                    color: AppTheme.secondary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: '회원당 평균',
                    value: '${_numberFormat.format(summary.averagePerMember.round())}원',
                    icon: Icons.analytics_outlined,
                    color: AppTheme.tertiary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: '결제 건수',
                    value: '${stats.paymentCount}건',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms);
          },
        );
      },
    );
  }

  /// 요약 카드 스켈레톤
  Widget _buildSummaryCardsSkeleton(bool isDark) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 120,
            margin: EdgeInsets.only(left: index > 0 ? 16 : 0),
            decoration: WebTheme.cardDecoration(context),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: isDark ? Colors.white10 : Colors.white),
        );
      }),
    );
  }

  /// 월별 매출 차트
  Widget _buildRevenueChart(BuildContext context, bool isDark, int selectedYear) {
    final chartDataAsync = ref.watch(monthlyRevenueChartProvider);

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$selectedYear년 월별 매출',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: chartDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('차트 로딩 실패: $e')),
              data: (data) => _buildBarChart(context, isDark, data),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  /// 바 차트
  Widget _buildBarChart(
    BuildContext context,
    bool isDark,
    List<MonthlyRevenue> data,
  ) {
    final maxRevenue = data.isEmpty
        ? 1000000.0
        : data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b).toDouble();
    final interval = (maxRevenue / 5).ceilToDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxRevenue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) =>
                isDark ? Colors.white : Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = group.x + 1;
              return BarTooltipItem(
                '$month월\n${_numberFormat.format(rod.toY.toInt())}원',
                TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${value.toInt() + 1}월',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval > 0 ? interval : 200000,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                String text;
                if (value >= 10000000) {
                  text = '${(value / 10000000).toStringAsFixed(0)}천만';
                } else if (value >= 10000) {
                  text = '${(value / 10000).toStringAsFixed(0)}만';
                } else {
                  text = _numberFormat.format(value.toInt());
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                );
              },
              reservedSize: 50,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval > 0 ? interval : 200000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.white10 : Colors.black12,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (index) {
          final monthData = data.firstWhere(
            (d) => d.month == index + 1,
            orElse: () => MonthlyRevenue(
              year: DateTime.now().year,
              month: index + 1,
              revenue: 0,
              count: 0,
            ),
          );
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: monthData.revenue.toDouble(),
                color: AppTheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// 결제 내역 테이블
  Widget _buildPaymentsTable(BuildContext context, bool isDark) {
    final paymentsAsync = ref.watch(monthlyPaymentsProvider);

    return Container(
      height: 500,
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '결제 내역',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              loading: () => _buildTableSkeleton(isDark),
              error: (e, _) => _buildErrorCard(e, isDark),
              data: (payments) {
                if (payments.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return _buildPlutoGrid(context, isDark, payments);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  /// PlutoGrid 테이블
  Widget _buildPlutoGrid(
    BuildContext context,
    bool isDark,
    List<PaymentRecordModel> payments,
  ) {
    final columns = <PlutoColumn>[
      PlutoColumn(
        title: '결제일',
        field: 'paymentDate',
        type: PlutoColumnType.date(),
        width: 120,
        renderer: (rendererContext) {
          final date = rendererContext.row.cells['paymentDate']?.value as DateTime?;
          return Center(
            child: Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : '-',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '회원명',
        field: 'memberName',
        type: PlutoColumnType.text(),
        width: 150,
        renderer: (rendererContext) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              rendererContext.row.cells['memberName']?.value ?? '-',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '금액',
        field: 'amount',
        type: PlutoColumnType.number(),
        width: 140,
        renderer: (rendererContext) {
          final amount = rendererContext.row.cells['amount']?.value as int? ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_numberFormat.format(amount)}원',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'PT 횟수',
        field: 'ptSessions',
        type: PlutoColumnType.number(),
        width: 100,
        renderer: (rendererContext) {
          final sessions = rendererContext.row.cells['ptSessions']?.value ?? 0;
          return Center(
            child: Text(
              '$sessions회',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '회당 단가',
        field: 'pricePerSession',
        type: PlutoColumnType.number(),
        width: 120,
        renderer: (rendererContext) {
          final price = (rendererContext.row.cells['pricePerSession']?.value as num?)?.toInt() ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_numberFormat.format(price)}원',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '결제 방법',
        field: 'paymentMethod',
        type: PlutoColumnType.text(),
        width: 100,
        renderer: (rendererContext) {
          final method = rendererContext.row.cells['paymentMethod']?.value as String? ?? '';
          return Center(
            child: _PaymentMethodBadge(method: method, isDark: isDark),
          );
        },
      ),
      PlutoColumn(
        title: '메모',
        field: 'memo',
        type: PlutoColumnType.text(),
        width: 200,
        renderer: (rendererContext) {
          final memo = rendererContext.row.cells['memo']?.value as String?;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              memo ?? '-',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          );
        },
      ),
    ];

    final rows = payments.map((payment) {
      return PlutoRow(
        cells: {
          'paymentDate': PlutoCell(value: payment.paymentDate),
          'memberName': PlutoCell(value: payment.memberName),
          'amount': PlutoCell(value: payment.amount),
          'ptSessions': PlutoCell(value: payment.ptSessions),
          'pricePerSession': PlutoCell(value: payment.pricePerSession),
          'paymentMethod': PlutoCell(value: payment.paymentMethodLabel),
          'memo': PlutoCell(value: payment.memo),
          'id': PlutoCell(value: payment.id),
        },
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: PlutoGrid(
        columns: columns,
        rows: rows,
        configuration: PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            gridBackgroundColor: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
            rowColor: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
            activatedColor: isDark
                ? AppTheme.primary.withValues(alpha: 0.2)
                : AppTheme.primary.withValues(alpha: 0.1),
            activatedBorderColor: AppTheme.primary,
            gridBorderColor: isDark ? Colors.white12 : Colors.black12,
            borderColor: isDark ? Colors.white12 : Colors.black12,
            cellTextStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            columnTextStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
            rowHeight: 52,
            columnHeight: 44,
          ),
          columnSize: const PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
          scrollbar: const PlutoGridScrollbarConfig(
            isAlwaysShown: false,
            scrollbarThickness: 8,
          ),
        ),
      ),
    );
  }

  /// 테이블 스켈레톤
  Widget _buildTableSkeleton(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1500.ms, color: isDark ? Colors.white10 : Colors.white);
      },
    );
  }

  /// 빈 상태
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            '이 달의 결제 내역이 없습니다',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showPaymentDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('결제 등록하기'),
          ),
        ],
      ),
    );
  }

  /// 에러 카드
  Widget _buildErrorCard(Object error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '데이터를 불러오지 못했습니다',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(paymentSummaryProvider);
              ref.invalidate(monthlyPaymentsProvider);
              ref.invalidate(monthlyRevenueChartProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 결제 등록 다이얼로그 표시
  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PaymentFormDialog(),
    );
  }
}

/// 매출 요약 카드 위젯
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 결제 방법 배지
class _PaymentMethodBadge extends StatelessWidget {
  final String method;
  final bool isDark;

  const _PaymentMethodBadge({
    required this.method,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (method) {
      case '현금':
        bgColor = AppTheme.secondary.withValues(alpha: 0.1);
        textColor = AppTheme.secondary;
        break;
      case '카드':
        bgColor = AppTheme.primary.withValues(alpha: 0.1);
        textColor = AppTheme.primary;
        break;
      case '계좌이체':
        bgColor = AppTheme.tertiary.withValues(alpha: 0.1);
        textColor = AppTheme.tertiary;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
