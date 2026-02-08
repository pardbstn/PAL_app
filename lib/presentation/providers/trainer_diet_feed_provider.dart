import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/diet_record_model.dart';
import 'package:flutter_pal_app/data/repositories/diet_record_repository.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';

/// 식단 사진 피드 아이템 (트레이너 홈용)
class DietPhotoFeedItem {
  final DietRecordModel record;
  final String memberName;
  final String? memberProfileUrl;
  final String memberId;

  const DietPhotoFeedItem({
    required this.record,
    required this.memberName,
    this.memberProfileUrl,
    required this.memberId,
  });
}

/// 트레이너의 전체 회원 최근 식단 사진 피드 (3일 이내, 이미지 있는 것만)
final recentMemberDietPhotosProvider =
    FutureProvider.autoDispose<List<DietPhotoFeedItem>>((ref) async {
  final membersAsync = ref.watch(membersProvider);
  final membersWithUserAsync = ref.watch(membersWithUserProvider);
  final dietRecordRepo = ref.watch(dietRecordRepositoryProvider);

  return membersAsync.when(
    loading: () => <DietPhotoFeedItem>[],
    error: (_, __) => <DietPhotoFeedItem>[],
    data: (members) async {
      if (members.isEmpty) return <DietPhotoFeedItem>[];

      return membersWithUserAsync.when(
        loading: () => <DietPhotoFeedItem>[],
        error: (_, __) => <DietPhotoFeedItem>[],
        data: (membersWithUser) async {
          // 회원 ID 목록 추출
          final memberIds = members.map((m) => m.id).toList();

          // 3일 전부터의 식단 기록 조회
          final threeDaysAgo =
              DateTime.now().subtract(const Duration(days: 3));
          final records = await dietRecordRepo.getRecentByMemberIds(
            memberIds,
            since: threeDaysAgo,
            limit: 20,
          );

          // 이미지가 있는 기록만 필터링
          final photoRecords = records.where((r) => r.hasImage).toList();

          // 회원 이름/프로필 매핑
          final memberMap = <String, MemberWithUser>{};
          for (final mwu in membersWithUser) {
            memberMap[mwu.member.id] = mwu;
          }

          // DietPhotoFeedItem으로 변환
          return photoRecords.map((record) {
            final mwu = memberMap[record.memberId];
            return DietPhotoFeedItem(
              record: record,
              memberName: mwu?.name ?? '회원',
              memberProfileUrl: mwu?.profileImageUrl,
              memberId: record.memberId,
            );
          }).toList();
        },
      );
    },
  );
});
