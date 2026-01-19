import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../../../presentation/widgets/states/states.dart';

// 웹이 아닐 때만 dart:io 사용
import 'dart:io' if (dart.library.html) 'dart:io';

/// 식단 아이템 모델
class DietItem {
  final String id;
  final String name;
  final int calories;
  final int carbs, protein, fat;
  final String? imagePath, memo;
  final DateTime createdAt;

  DietItem({
    required this.id,
    required this.name,
    required this.calories,
    this.carbs = 0,
    this.protein = 0,
    this.fat = 0,
    this.imagePath,
    this.memo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// 식사 타입 정의
enum MealType {
  breakfast('breakfast', '아침', '🌅', Color(0xFFFFB347)),
  lunch('lunch', '점심', '☀️', Color(0xFFFFD700)),
  dinner('dinner', '저녁', '🌙', Color(0xFF9370DB)),
  snack('snack', '간식', '🍎', Color(0xFF90EE90));

  final String key, label, emoji;
  final Color color;
  const MealType(this.key, this.label, this.emoji, this.color);
}

/// 회원 식단 기록 화면 (프리미엄 UI)
class MemberDietScreen extends ConsumerStatefulWidget {
  const MemberDietScreen({super.key});

  @override
  ConsumerState<MemberDietScreen> createState() => _MemberDietScreenState();
}

class _MemberDietScreenState extends ConsumerState<MemberDietScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  Object? _error;
  final int _targetCalories = 1800;
  final ImagePicker _picker = ImagePicker();
  final Map<String, List<DietItem>> _dietItems = {
    'breakfast': [], 'lunch': [], 'dinner': [], 'snack': [],
  };

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  /// 더미 데이터 로드
  Future<void> _loadDummyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (_isToday(_selectedDate)) {
        _dietItems['breakfast'] = [
          DietItem(id: '1', name: '그릭요거트 & 그래놀라', calories: 320, carbs: 35, protein: 18, fat: 12),
          DietItem(id: '2', name: '아메리카노', calories: 5, carbs: 1, protein: 0, fat: 0),
        ];
        _dietItems['lunch'] = [
          DietItem(id: '3', name: '닭가슴살 샐러드', calories: 450, carbs: 20, protein: 45, fat: 18),
        ];
        _dietItems['dinner'] = [];
        _dietItems['snack'] = [
          DietItem(id: '4', name: '프로틴 바', calories: 200, carbs: 22, protein: 20, fat: 8),
        ];
      } else {
        _dietItems.forEach((key, _) => _dietItems[key] = []);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e;
      });
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  int get _totalCalories => _dietItems.values.expand((e) => e).fold(0, (s, i) => s + i.calories);

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _loadDummyData();
  }

  /// 식단 추가 바텀시트
  Future<void> _showAddDietBottomSheet(MealType mealType) async {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final memoCtrl = TextEditingController();
    String? imagePath;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final cs = Theme.of(ctx).colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Row(children: [
                    Text(mealType.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text('${mealType.label} 추가', style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 24),
                  // 사진 선택 영역
                  GestureDetector(
                    onTap: () async {
                      final source = await _showImageSourceDialog();
                      if (source != null) {
                        final img = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
                        if (img != null) setModalState(() => imagePath = img.path);
                      }
                    },
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                        image: imagePath != null && !kIsWeb ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover) : null,
                      ),
                      child: imagePath == null
                          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.add_a_photo_outlined, size: 28, color: cs.primary)),
                              const SizedBox(height: 8),
                              Text('사진 추가하기', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                            ])
                          : Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(8), child: GestureDetector(onTap: () => setModalState(() => imagePath = null), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18))))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: InputDecoration(labelText: '음식명', hintText: '예: 닭가슴살 샐러드', prefixIcon: const Icon(Icons.restaurant_outlined), filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5))),
                  const SizedBox(height: 12),
                  TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '칼로리 (선택)', hintText: '예: 350', suffixText: 'kcal', prefixIcon: const Icon(Icons.local_fire_department_outlined), filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5))),
                  const SizedBox(height: 12),
                  TextField(controller: memoCtrl, maxLines: 2, decoration: InputDecoration(labelText: '메모 (선택)', hintText: '예: 운동 후 먹음', prefixIcon: const Icon(Icons.note_outlined), filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5))),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('음식명을 입력해주세요'), behavior: SnackBarBehavior.floating));
                          return;
                        }
                        setState(() => _dietItems[mealType.key]!.add(DietItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          calories: int.tryParse(calCtrl.text) ?? 0,
                          imagePath: imagePath,
                          memo: memoCtrl.text.trim().isEmpty ? null : memoCtrl.text.trim(),
                        )));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${mealType.label}에 추가되었습니다'), behavior: SnackBarBehavior.floating, backgroundColor: AppTheme.secondary));
                      },
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('추가하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 이미지 소스 선택 다이얼로그
  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('사진 선택', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _buildSourceOption(ctx, Icons.camera_alt_outlined, '카메라', () => Navigator.pop(ctx, ImageSource.camera))),
              const SizedBox(width: 16),
              Expanded(child: _buildSourceOption(ctx, Icons.photo_library_outlined, '갤러리', () => Navigator.pop(ctx, ImageSource.gallery))),
            ]),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }

  Widget _buildSourceOption(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(icon, size: 28, color: cs.primary),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
        ]),
      ),
    );
  }

  void _deleteDietItem(MealType mealType, DietItem item) {
    setState(() => _dietItems[mealType.key]!.removeWhere((i) => i.id == item.id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${item.name}이(가) 삭제되었습니다'),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(label: '취소', onPressed: () => setState(() => _dietItems[mealType.key]!.add(item))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('식단 기록'), centerTitle: true, elevation: 0, scrolledUnderElevation: 1),
      body: SafeArea(
        child: Column(children: [
          _buildDateSelector(cs, tt),
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading(cs)
                : _error != null
                    ? ErrorState.fromError(_error!, onRetry: _loadDummyData)
                    : _buildContent(cs, tt),
          ),
        ]),
      ),
    );
  }

  /// 날짜 선택 위젯
  Widget _buildDateSelector(ColorScheme cs, TextTheme tt) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: cs.surface, border: Border(bottom: BorderSide(color: cs.outline.withValues(alpha: 0.1)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton.filled(onPressed: () => _changeDate(-1), icon: const Icon(Icons.chevron_left), style: IconButton.styleFrom(backgroundColor: cs.surfaceContainerHighest, foregroundColor: cs.onSurface)),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 7)));
            if (picked != null) { setState(() => _selectedDate = picked); _loadDummyData(); }
          },
          child: Column(children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(dateFormat.format(_selectedDate), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 20, color: cs.onSurface.withValues(alpha: 0.5)),
            ]),
            if (isToday) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('오늘', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary))),
          ]),
        ),
        IconButton.filled(onPressed: () => _changeDate(1), icon: const Icon(Icons.chevron_right), style: IconButton.styleFrom(backgroundColor: cs.surfaceContainerHighest, foregroundColor: cs.onSurface)),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 스켈레톤 로딩
  Widget _buildShimmerLoading(ColorScheme cs) {
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest,
      highlightColor: cs.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => Container(height: i == 0 ? 120 : 100, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }

  /// 메인 컨텐츠
  Widget _buildContent(ColorScheme cs, TextTheme tt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCalorieSummaryCard(cs, tt).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 20),
        ...MealType.values.asMap().entries.map((e) => _buildMealSection(e.value, cs, tt).animate(delay: Duration(milliseconds: 100 * e.key)).fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0)),
        const SizedBox(height: 80),
      ]),
    );
  }

  /// 칼로리 요약 카드
  Widget _buildCalorieSummaryCard(ColorScheme cs, TextTheme tt) {
    final progress = (_totalCalories / _targetCalories).clamp(0.0, 1.0);
    final isOver = _totalCalories > _targetCalories;
    final fmt = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cs.primary, cs.primary.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('오늘 총 섭취', style: tt.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(fmt.format(_totalCalories), style: tt.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('kcal', style: tt.bodyLarge?.copyWith(color: Colors.white70))),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text('목표', style: tt.bodySmall?.copyWith(color: Colors.white70)),
              Text('${fmt.format(_targetCalories)} kcal', style: tt.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(isOver ? AppTheme.error : Colors.white))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(progress * 100).toInt()}% 달성', style: tt.bodySmall?.copyWith(color: Colors.white70)),
          Text(isOver ? '${fmt.format(_totalCalories - _targetCalories)} kcal 초과' : '${fmt.format(_targetCalories - _totalCalories)} kcal 남음', style: tt.bodySmall?.copyWith(color: isOver ? const Color(0xFFFFCDD2) : Colors.white70, fontWeight: isOver ? FontWeight.w600 : null)),
        ]),
      ]),
    );
  }

  /// 식사별 섹션
  Widget _buildMealSection(MealType mealType, ColorScheme cs, TextTheme tt) {
    final items = _dietItems[mealType.key] ?? [];
    final sectionCal = items.fold<int>(0, (s, i) => s + i.calories);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outline.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: mealType.color.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: mealType.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(mealType.emoji, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mealType.label, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (items.isNotEmpty) Text('${NumberFormat('#,###').format(sectionCal)} kcal', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
            ])),
            IconButton.filled(onPressed: () => _showAddDietBottomSheet(mealType), icon: const Icon(Icons.add), style: IconButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary)),
          ]),
        ),
        // 아이템 목록 또는 빈 상태
        if (items.isEmpty) _buildEmptyMealState(mealType, cs, tt)
        else ...items.map((item) => _buildDietItemTile(item, mealType, cs, tt)),
      ]),
    );
  }

  /// 빈 식사 상태
  Widget _buildEmptyMealState(MealType mealType, ColorScheme cs, TextTheme tt) {
    return InkWell(
      onTap: () => _showAddDietBottomSheet(mealType),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: EmptyState(
          type: EmptyStateType.dietRecords,
          customTitle: '${mealType.label} 기록이 없어요',
          customMessage: '탭하여 ${mealType.label}을 추가해보세요',
          iconSize: 60,
          onAction: () => _showAddDietBottomSheet(mealType),
        ),
      ),
    );
  }

  /// 식단 아이템 타일
  Widget _buildDietItemTile(DietItem item, MealType mealType, ColorScheme cs, TextTheme tt) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteDietItem(mealType, item),
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))), child: Icon(Icons.delete_outline, color: AppTheme.error)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.1)))),
        child: Row(children: [
          // 썸네일
          Container(width: 52, height: 52, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12), image: item.imagePath != null && !kIsWeb ? DecorationImage(image: FileImage(File(item.imagePath!)), fit: BoxFit.cover) : null), child: item.imagePath == null || kIsWeb ? Icon(Icons.restaurant, color: cs.onSurface.withValues(alpha: 0.3)) : null),
          const SizedBox(width: 12),
          // 정보
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text('${item.calories} kcal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary))),
              if (item.carbs > 0 || item.protein > 0 || item.fat > 0) ...[const SizedBox(width: 8), Text('탄${item.carbs} / 단${item.protein} / 지${item.fat}', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)))],
            ]),
            if (item.memo != null) ...[const SizedBox(height: 4), Text(item.memo!, style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5), fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis)],
          ])),
          Icon(Icons.chevron_left, color: cs.onSurface.withValues(alpha: 0.2), size: 20),
        ]),
      ),
    );
  }
}
