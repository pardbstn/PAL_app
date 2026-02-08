import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ============================================================================
// 레거시 Shimmer 기반 컴포넌트 (하위 호환성)
// ============================================================================

/// 다크모드 대응 Shimmer 컨테이너
class SkeletonContainer extends StatelessWidget {
  final Widget child;

  const SkeletonContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBEBEB),
      highlightColor: isDark
          ? const Color(0xFF475569)
          : const Color(0xFFF4F4F4),
      child: child,
    );
  }
}

/// 기본 스켈레톤 박스
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 스켈레톤 원형 (아바타용)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 스켈레톤 텍스트 라인
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: width, height: height, borderRadius: 4);
  }
}

// ============================================================================
// Skeletonizer 기반 신규 컴포넌트
// ============================================================================

/// Skeletonizer 기반 스켈레톤 래퍼
/// 실제 위젯을 그대로 사용하면서 로딩 상태 표시
///
/// Impeller 렌더링 최적화를 위해 RepaintBoundary로 감쌈
class AppSkeletonizer extends StatelessWidget {
  /// 로딩 상태 여부
  final bool isLoading;

  /// 스켈레톤으로 표시할 자식 위젯
  final Widget child;

  /// 컨테이너 요소 무시 여부 (기본값: false)
  final bool ignoreContainers;

  /// 컨테이너 배경색 유지 여부 (기본값: false)
  final bool containersColor;

  /// 애니메이션 효과 (기본값: shimmer)
  final PaintingEffect? effect;

  const AppSkeletonizer({
    super.key,
    required this.isLoading,
    required this.child,
    this.ignoreContainers = false,
    this.containersColor = false,
    this.effect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 다크모드별 색상 설정
    final baseColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEBEBEB);
    final highlightColor = isDark
        ? const Color(0xFF475569)
        : const Color(0xFFF4F4F4);

    return RepaintBoundary(
      child: Skeletonizer(
        enabled: isLoading,
        ignoreContainers: ignoreContainers,
        containersColor: containersColor
            ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F4))
            : null,
        effect:
            effect ??
            ShimmerEffect(
              baseColor: baseColor,
              highlightColor: highlightColor,
              duration: const Duration(milliseconds: 1200),
            ),
        child: child,
      ),
    );
  }
}

/// 설정 화면용 스켈레톤
/// 프로필 헤더 + 리스트 그룹으로 구성
class SettingsScreenSkeleton extends StatelessWidget {
  const SettingsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 프로필 헤더
        const SkeletonizerProfileHeader(avatarSize: 80),
        const SizedBox(height: 32),

        // 리스트 그룹 1
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ListItemSkeleton(hasLeading: true, hasTrailing: true),
          ),
        ),

        const SizedBox(height: 24),

        // 리스트 그룹 2
        ...List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ListItemSkeleton(
              hasLeading: true,
              hasSubtitle: true,
              hasTrailing: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// 회원 상세 화면용 스켈레톤
/// 헤더 + 탭 콘텐츠로 구성
class MemberDetailSkeleton extends StatelessWidget {
  const MemberDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 프로필 헤더
        Container(
          padding: const EdgeInsets.all(24),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const SkeletonizerProfileHeader(avatarSize: 96),
        ),

        const SizedBox(height: 16),

        // 탭 콘텐츠
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 통계 카드
              Row(
                children: [
                  Expanded(child: CardSkeleton(height: 120)),
                  const SizedBox(width: 12),
                  Expanded(child: CardSkeleton(height: 120)),
                ],
              ),

              const SizedBox(height: 24),

              // 차트
              const SkeletonizerChart(height: 200),

              const SizedBox(height: 24),

              // 리스트 아이템
              ...List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ListItemSkeleton(hasSubtitle: true, hasTrailing: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 리스트 아이템 스켈레톤
class ListItemSkeleton extends StatelessWidget {
  final bool hasLeading;
  final bool hasSubtitle;
  final bool hasTrailing;

  const ListItemSkeleton({
    super.key,
    this.hasLeading = false,
    this.hasSubtitle = false,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: hasLeading ? const Bone.circle(size: 40) : null,
        title: const Bone.text(words: 3),
        subtitle: hasSubtitle ? const Bone.text(words: 5) : null,
        trailing: hasTrailing ? const Bone.icon() : null,
      ),
    );
  }
}

/// 카드 스켈레톤
class CardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;

  const CardSkeleton({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: width,
        height: height ?? 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Bone.text(words: 2),
            const Spacer(),
            const Bone.text(words: 1, fontSize: 28),
          ],
        ),
      ),
    );
  }
}

/// 프로필 헤더 스켈레톤 (Skeletonizer 버전)
class SkeletonizerProfileHeader extends StatelessWidget {
  final double avatarSize;

  const SkeletonizerProfileHeader({super.key, this.avatarSize = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Bone.circle(size: avatarSize),
        const SizedBox(height: 16),
        const Bone.text(words: 2, fontSize: 20),
        const SizedBox(height: 8),
        const Bone.text(words: 4, fontSize: 14),
      ],
    );
  }
}

/// 차트 스켈레톤 (Skeletonizer 버전)
class SkeletonizerChart extends StatelessWidget {
  final double height;

  const SkeletonizerChart({super.key, this.height = 250});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Bone.text(words: 3, fontSize: 18),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  7,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Bone.square(
                        size: 40 + (index % 3) * 30.0,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
