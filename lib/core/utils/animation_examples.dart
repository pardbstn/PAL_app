import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// 프리미엄 애니메이션 사용 예시
///
/// PAL 앱의 주요 화면에서 고급 애니메이션을 적용하는 방법을 보여줍니다.
/// 실제 프로젝트에서 복사해서 사용할 수 있는 실용적인 예제들입니다.

// ========================================
// 1. 대시보드 카드 그리드
// ========================================

class AnimatedDashboardGrid extends StatelessWidget {
  const AnimatedDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        // 프리미엄 카드 스태거 효과
        return _DashboardCard(
          title: '카드 ${index + 1}',
          value: '${(index + 1) * 100}',
        ).animatePremiumCard(index);
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const _DashboardCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// 2. 회원 목록 (리스트 스태거)
// ========================================

class AnimatedMemberList extends StatelessWidget {
  final List<String> members;

  const AnimatedMemberList({
    super.key,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        // 개선된 리스트 스태거 효과 (최대 8개까지만 지연)
        return ListTile(
          leading: CircleAvatar(
            child: Text(members[index][0]),
          ).animateProfileEntrance(), // 프로필 전용 애니메이션
          title: Text(members[index]),
          subtitle: const Text('회원'),
          trailing: const Icon(Icons.chevron_right),
        ).animateListItemStagger(index, maxStagger: 8);
      },
    );
  }
}

// ========================================
// 3. 프로필 헤더 (섹션 등장)
// ========================================

class AnimatedProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;

  const AnimatedProfileHeader({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          // 프로필 이미지 - 전용 애니메이션
          CircleAvatar(
            radius: 50,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null ? const Icon(Icons.person, size: 50) : null,
          ).animateProfileEntrance(),

          const SizedBox(height: 16),

          // 이름 - 프리미엄 등장
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ).animatePremiumEntrance(delay: const Duration(milliseconds: 200)),

          const SizedBox(height: 4),

          // 역할 - 프리미엄 등장
          Text(
            role,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ).animatePremiumEntrance(delay: const Duration(milliseconds: 300)),
        ],
      ),
    ).animateSectionEntrance(); // 전체 섹션 등장
  }
}

// ========================================
// 4. 통계 섹션 (섹션 등장 + 카드 스태거)
// ========================================

class AnimatedStatsSection extends StatelessWidget {
  const AnimatedStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '이번 달 통계',
            style: Theme.of(context).textTheme.titleLarge,
          ).animatePremiumEntrance(),
        ),

        // 통계 카드들
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStatIcon(index),
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(index + 1) * 25}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatLabel(index),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ).animatePremiumCard(index);
            },
          ),
        ),
      ],
    ).animateSectionEntrance(delay: const Duration(milliseconds: 100));
  }

  IconData _getStatIcon(int index) {
    switch (index) {
      case 0:
        return Icons.fitness_center;
      case 1:
        return Icons.people;
      case 2:
        return Icons.calendar_today;
      case 3:
        return Icons.trending_up;
      default:
        return Icons.star;
    }
  }

  String _getStatLabel(int index) {
    switch (index) {
      case 0:
        return 'PT 세션';
      case 1:
        return '활성 회원';
      case 2:
        return '이번 주';
      case 3:
        return '목표 달성';
      default:
        return '';
    }
  }
}

// ========================================
// 5. 폼 검증 피드백 (에러 & 성공)
// ========================================

class AnimatedFormField extends StatefulWidget {
  const AnimatedFormField({super.key});

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField> {
  final _controller = TextEditingController();
  bool _hasError = false;
  bool _isSuccess = false;

  void _validate() {
    final text = _controller.text;
    setState(() {
      _hasError = text.isEmpty;
      _isSuccess = text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget field = TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: '회원 이름',
        errorText: _hasError ? '이름을 입력해주세요' : null,
        suffixIcon: _isSuccess
            ? const Icon(Icons.check_circle, color: Colors.green)
                .animateSuccessBounce() // 성공 바운스
            : null,
      ),
    );

    // 에러 상태면 흔들기
    if (_hasError) {
      field = field.animateErrorShake();
    }

    return Column(
      children: [
        field,
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _validate,
          child: const Text('검증'),
        ),
      ],
    );
  }
}

// ========================================
// 6. CTA 버튼 (주목 효과)
// ========================================

class AnimatedCTAButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AnimatedCTAButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ).animateButtonAttention(); // 버튼 강조 펄스
  }
}

// ========================================
// 7. 스켈레톤 로더
// ========================================

class AnimatedSkeletonLoader extends StatelessWidget {
  const AnimatedSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 원형 스켈레톤 (프로필)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ).animateLoadingPulse(), // 무한 펄스

              const SizedBox(width: 16),

              // 텍스트 스켈레톤
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animateLoadingPulse(),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animateLoadingPulse(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// 8. 빈 상태 화면 (Empty State)
// ========================================

class AnimatedEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AnimatedEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ).animateProfileEntrance(), // 프로필 등장 효과 재사용

          const SizedBox(height: 24),

          // 메시지
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ).animatePremiumEntrance(delay: const Duration(milliseconds: 200)),
        ],
      ),
    );
  }
}

// ========================================
// 9. 알림 배너
// ========================================

class AnimatedNotificationBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const AnimatedNotificationBanner({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget banner = Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );

    // 에러면 흔들기, 아니면 프리미엄 등장
    return isError ? banner.animateErrorShake() : banner.animatePremiumEntrance();
  }
}

// ========================================
// 10. 풀스크린 데모 페이지
// ========================================

/// 모든 애니메이션을 한눈에 볼 수 있는 데모 화면
class AnimationDemoScreen extends StatelessWidget {
  const AnimationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프리미엄 애니메이션 데모'),
      ),
      body: ListView(
        children: [
          // 프로필 헤더
          const AnimatedProfileHeader(
            name: '홍길동 트레이너',
            role: 'PT 전문가',
          ),

          const SizedBox(height: 24),

          // 통계 섹션
          const AnimatedStatsSection(),

          const SizedBox(height: 24),

          // 대시보드 그리드
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '대시보드',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 400,
            child: AnimatedDashboardGrid(),
          ),

          const SizedBox(height: 24),

          // 폼 검증
          const Padding(
            padding: EdgeInsets.all(16),
            child: AnimatedFormField(),
          ),

          const SizedBox(height: 24),

          // CTA 버튼
          Center(
            child: AnimatedCTAButton(
              onPressed: () {},
              label: 'PT 세션 시작',
            ),
          ),

          const SizedBox(height: 24),

          // 알림 배너
          const AnimatedNotificationBanner(
            message: 'PT 기록이 성공적으로 저장됐어요',
          ),

          const SizedBox(height: 16),

          const AnimatedNotificationBanner(
            message: '네트워크에 문제가 생겼어요',
            isError: true,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
