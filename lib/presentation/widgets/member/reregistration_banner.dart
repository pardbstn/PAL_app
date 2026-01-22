import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/reregistration_alert_model.dart';
import '../../providers/reregistration_provider.dart';

/// 재등록 배너 - 회원 홈 화면에 표시
/// PT 진행률이 80% 이상일 때 재등록을 유도하는 배너
class ReregistrationBanner extends ConsumerStatefulWidget {
  const ReregistrationBanner({
    super.key,
    required this.memberId,
    this.onContactTrainer,
    this.onDismiss,
  });

  /// 회원 ID
  final String memberId;

  /// 트레이너에게 문의 버튼 콜백
  final VoidCallback? onContactTrainer;

  /// 배너 닫기 콜백
  final VoidCallback? onDismiss;

  @override
  ConsumerState<ReregistrationBanner> createState() =>
      _ReregistrationBannerState();
}

class _ReregistrationBannerState extends ConsumerState<ReregistrationBanner>
    with SingleTickerProviderStateMixin {
  static const String _dismissKeyPrefix = 'reregistration_banner_dismissed_';
  static const Duration _dismissDuration = Duration(hours: 24);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _checkDismissStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkDismissStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedAt = prefs.getInt('$_dismissKeyPrefix${widget.memberId}');

    if (dismissedAt != null) {
      final dismissedTime = DateTime.fromMillisecondsSinceEpoch(dismissedAt);
      if (DateTime.now().difference(dismissedTime) < _dismissDuration) {
        setState(() => _isDismissed = true);
        return;
      }
    }

    _animationController.forward();
  }

  Future<void> _handleDismiss() async {
    await _animationController.reverse();
    setState(() => _isDismissed = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_dismissKeyPrefix${widget.memberId}',
      DateTime.now().millisecondsSinceEpoch,
    );

    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    final alertAsync = ref.watch(memberReregistrationAlertProvider(widget.memberId));

    return alertAsync.when(
      data: (alert) {
        if (alert == null || alert.progressRate < 0.8 || alert.reregistered) {
          return const SizedBox.shrink();
        }
        return _buildBanner(context, alert);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, ReregistrationAlertModel alert) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E40AF),
                      const Color(0xFF7C3AED),
                    ]
                  : [
                      AppTheme.primary,
                      const Color(0xFF8B5CF6),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 배경 장식
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // 컨텐츠
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더 영역
                    Row(
                      children: [
                        // 아이콘
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 타이틀
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '수업 거의 완료!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '지금까지 잘 해오셨어요',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 닫기 버튼
                        GestureDetector(
                          onTap: _handleDismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 진행률 표시
                    _buildProgressSection(alert),

                    const SizedBox(height: 20),

                    // CTA 버튼
                    _buildCtaButton(context, colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(ReregistrationAlertModel alert) {
    final progressPercent = (alert.progressRate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // 진행률 텍스트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${alert.totalSessions}회 중 ${alert.completedSessions}회 완료!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: alert.progressRate,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // 남은 회차 안내
          Text(
            '${alert.remainingSessions}회만 더 완료하면 목표 달성!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onContactTrainer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 18),
            SizedBox(width: 8),
            Text(
              '트레이너에게 문의',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 컴팩트 버전 재등록 배너 (작은 공간에 표시)
class ReregistrationBannerCompact extends ConsumerWidget {
  const ReregistrationBannerCompact({
    super.key,
    required this.memberId,
    this.onTap,
  });

  final String memberId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertAsync = ref.watch(memberReregistrationAlertProvider(memberId));

    return alertAsync.when(
      data: (alert) {
        if (alert == null || alert.progressRate < 0.8 || alert.reregistered) {
          return const SizedBox.shrink();
        }
        return _buildCompactBanner(context, alert);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCompactBanner(BuildContext context, ReregistrationAlertModel alert) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E40AF), const Color(0xFF7C3AED)]
                : [AppTheme.primary, const Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${alert.completedSessions}/${alert.totalSessions}회 완료 - 재등록 안내',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.7),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
