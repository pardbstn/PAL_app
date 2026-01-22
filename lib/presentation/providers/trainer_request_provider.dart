import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trainer_request_model.dart';
import '../../data/repositories/trainer_request_repository.dart';
import '../../data/services/self_training_service.dart';

/// 회원의 트레이너 요청 목록 실시간 감시
final memberRequestsProvider = StreamProvider.family<List<TrainerRequestModel>, String>((ref, memberId) {
  final repository = ref.watch(trainerRequestRepositoryProvider);
  return repository.watchByMemberId(memberId);
});

/// 트레이너의 대기 중인 요청 실시간 감시
final trainerPendingRequestsProvider = StreamProvider.family<List<TrainerRequestModel>, String>((ref, trainerId) {
  final repository = ref.watch(trainerRequestRepositoryProvider);
  return repository.watchPendingByTrainerId(trainerId);
});

/// 트레이너의 대기 요청 수 실시간 감시
final pendingRequestCountProvider = StreamProvider.family<int, String>((ref, trainerId) {
  final repository = ref.watch(trainerRequestRepositoryProvider);
  return repository.watchPendingCount(trainerId);
});

/// 트레이너 월간 수익
final trainerMonthlyRevenueProvider = FutureProvider.family<int, String>((ref, trainerId) async {
  final service = ref.watch(selfTrainingServiceProvider);
  return service.calculateMonthlyRevenue(trainerId);
});

/// 트레이너 요청 관리 Notifier
class TrainerRequestNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 트레이너에게 질문 요청
  Future<String?> createRequest({
    required String memberId,
    required String trainerId,
    required RequestType requestType,
    required String content,
    List<String>? attachmentUrls,
  }) async {
    final service = ref.read(selfTrainingServiceProvider);
    return await service.createTrainerRequest(
      memberId: memberId,
      trainerId: trainerId,
      requestType: requestType,
      content: content,
      attachmentUrls: attachmentUrls,
    );
  }

  /// 트레이너 답변 등록
  Future<void> submitResponse(String requestId, String response) async {
    final service = ref.read(selfTrainingServiceProvider);
    await service.submitTrainerResponse(requestId, response);
  }
}

final trainerRequestNotifierProvider = AsyncNotifierProvider<TrainerRequestNotifier, void>(() {
  return TrainerRequestNotifier();
});
