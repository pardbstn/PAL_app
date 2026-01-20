import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// 회원 카드 스켈레톤
class MemberCardSkeleton extends StatelessWidget {
  const MemberCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            SkeletonCircle(size: 56),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 120, height: 18),
                  SizedBox(height: 8),
                  SkeletonLine(width: 80, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 8, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 회원 목록 스켈레톤
class MemberListSkeleton extends StatelessWidget {
  final int itemCount;

  const MemberListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const MemberCardSkeleton(),
    );
  }
}

/// 통계 카드 스켈레톤
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonCircle(size: 40),
            SizedBox(height: 12),
            SkeletonLine(width: 60, height: 28),
            SizedBox(height: 8),
            SkeletonLine(width: 80, height: 14),
          ],
        ),
      ),
    );
  }
}

/// 대시보드 스켈레톤
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인사말
          const SkeletonContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 100, height: 14),
                SizedBox(height: 8),
                SkeletonLine(width: 180, height: 28),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 통계 카드들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (_) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: StatCardSkeleton(),
              )),
            ),
          ),
          const SizedBox(height: 24),
          // 오늘의 일정
          SkeletonContainer(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 차트
          const ChartSkeleton(),
        ],
      ),
    );
  }
}

/// 차트 스켈레톤
class ChartSkeleton extends StatelessWidget {
  final double height;

  const ChartSkeleton({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 120, height: 18),
          const SizedBox(height: 16),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}

/// 캘린더 스켈레톤
class CalendarSkeleton extends StatelessWidget {
  const CalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Column(
        children: [
          // 월 네비게이션
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SkeletonLine(width: 150, height: 24),
          ),
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (_) => const SkeletonBox(width: 30, height: 16)),
          ),
          const SizedBox(height: 8),
          // 날짜 그리드 (5주)
          ...List.generate(5, (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (_) => const SkeletonCircle(size: 36)),
            ),
          )),
        ],
      ),
    );
  }
}

/// 일정 목록 스켈레톤
class ScheduleListSkeleton extends StatelessWidget {
  final int itemCount;

  const ScheduleListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SkeletonLine(width: 50, height: 16),
              SizedBox(width: 12),
              SkeletonCircle(size: 32),
              SizedBox(width: 12),
              Expanded(child: SkeletonLine(height: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 커리큘럼 목록 스켈레톤
class CurriculumListSkeleton extends StatelessWidget {
  final int itemCount;

  const CurriculumListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Column(
        children: List.generate(itemCount, (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SkeletonCircle(size: 40),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 150, height: 16),
                    SizedBox(height: 4),
                    SkeletonLine(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

/// 프로필 헤더 스켈레톤
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonContainer(
      child: Column(
        children: [
          SkeletonCircle(size: 80),
          SizedBox(height: 16),
          SkeletonLine(width: 120, height: 24),
          SizedBox(height: 8),
          SkeletonLine(width: 80, height: 16),
        ],
      ),
    );
  }
}

/// 운동 기록 타임라인 스켈레톤
class ExerciseTimelineSkeleton extends StatelessWidget {
  final int itemCount;

  const ExerciseTimelineSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Column(
        children: List.generate(itemCount, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타임라인 인디케이터
              Column(
                children: [
                  const SkeletonCircle(size: 12),
                  if (index < itemCount - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.white,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // 내용
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 100, height: 14),
                    SizedBox(height: 4),
                    SkeletonLine(height: 18),
                    SizedBox(height: 4),
                    SkeletonLine(width: 150, height: 14),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

/// 인사이트 카드 스켈레톤
class InsightCardSkeleton extends StatelessWidget {
  const InsightCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 아이콘 + 제목
            Row(
              children: [
                SkeletonCircle(size: 40),
                SizedBox(width: 12),
                Expanded(child: SkeletonLine(width: 150, height: 18)),
              ],
            ),
            SizedBox(height: 16),
            // 본문 텍스트 3줄
            SkeletonLine(height: 14),
            SizedBox(height: 8),
            SkeletonLine(height: 14),
            SizedBox(height: 8),
            SkeletonLine(width: 200, height: 14),
            SizedBox(height: 16),
            // 하단: 날짜
            SkeletonLine(width: 100, height: 12),
          ],
        ),
      ),
    );
  }
}

/// 인사이트 목록 스켈레톤
class InsightListSkeleton extends StatelessWidget {
  final int itemCount;

  const InsightListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const InsightCardSkeleton(),
    );
  }
}

/// 채팅 목록 아이템 스켈레톤
class ChatListItemSkeleton extends StatelessWidget {
  const ChatListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 아바타
            const SkeletonCircle(size: 48),
            const SizedBox(width: 12),
            // 이름 + 마지막 메시지
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 100, height: 16),
                  SizedBox(height: 6),
                  SkeletonLine(width: 180, height: 14),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 시간 + 읽지 않은 메시지 배지
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SkeletonLine(width: 40, height: 12),
                const SizedBox(height: 6),
                SkeletonCircle(size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 채팅 목록 스켈레톤
class ChatListSkeleton extends StatelessWidget {
  final int itemCount;

  const ChatListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (_, _) => const ChatListItemSkeleton(),
    );
  }
}
