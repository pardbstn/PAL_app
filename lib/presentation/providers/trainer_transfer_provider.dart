import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_transfer_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_transfer_repository.dart';

/// 회원의 대기 중인 전환 요청 목록 (실시간 스트림)
final pendingTransfersProvider =
    StreamProvider.family<List<TrainerTransferModel>, String>((ref, memberId) {
  final repository = ref.watch(trainerTransferRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchPendingForMember(memberId);
});

/// 회원의 모든 전환 이력 조회
final memberTransferHistoryProvider =
    FutureProvider.family<List<TrainerTransferModel>, String>(
        (ref, memberId) async {
  final repository = ref.watch(trainerTransferRepositoryProvider);

  if (memberId.isEmpty) {
    return [];
  }

  return repository.getByMemberId(memberId);
});

/// 트레이너의 모든 전환 이력 조회 (발신/수신 모두)
final trainerTransferHistoryProvider =
    FutureProvider.family<List<TrainerTransferModel>, String>(
        (ref, trainerId) async {
  final repository = ref.watch(trainerTransferRepositoryProvider);

  if (trainerId.isEmpty) {
    return [];
  }

  return repository.getByTrainerId(trainerId);
});

/// 전환 요청 액션 상태
enum TransferActionStatus {
  idle,
  loading,
  success,
  error,
}

/// 전환 요청 액션 상태 클래스
class TransferActionState {
  final TransferActionStatus status;
  final String? errorMessage;

  const TransferActionState({
    required this.status,
    this.errorMessage,
  });

  const TransferActionState.idle()
      : status = TransferActionStatus.idle,
        errorMessage = null;

  const TransferActionState.loading()
      : status = TransferActionStatus.loading,
        errorMessage = null;

  const TransferActionState.success()
      : status = TransferActionStatus.success,
        errorMessage = null;

  const TransferActionState.error(this.errorMessage)
      : status = TransferActionStatus.error;

  bool get isLoading => status == TransferActionStatus.loading;
  bool get isSuccess => status == TransferActionStatus.success;
  bool get isError => status == TransferActionStatus.error;
  bool get isIdle => status == TransferActionStatus.idle;

  TransferActionState copyWith({
    TransferActionStatus? status,
    String? errorMessage,
  }) {
    return TransferActionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 트레이너 전환 관리 Notifier
class TrainerTransferNotifier extends Notifier<TransferActionState> {
  TrainerTransferRepository get _repository =>
      ref.read(trainerTransferRepositoryProvider);

  @override
  TransferActionState build() {
    return const TransferActionState.idle();
  }

  /// 전환 요청 생성
  Future<void> initiateTransfer({
    required String memberId,
    required String memberName,
    required String fromTrainerId,
    required String fromTrainerName,
    required String toTrainerId,
    required String toTrainerName,
    String reason = '',
  }) async {
    state = const TransferActionState.loading();
    try {
      final transfer = TrainerTransferModel(
        memberId: memberId,
        memberName: memberName,
        fromTrainerId: fromTrainerId,
        fromTrainerName: fromTrainerName,
        toTrainerId: toTrainerId,
        toTrainerName: toTrainerName,
        status: TransferStatus.pending,
        reason: reason,
        requestedAt: DateTime.now(),
      );

      await _repository.create(transfer);
      state = const TransferActionState.success();
    } catch (e) {
      state = TransferActionState.error(e.toString());
      rethrow;
    }
  }

  /// 전환 요청 수락
  Future<void> acceptTransfer(String transferId) async {
    state = const TransferActionState.loading();
    try {
      await _repository.acceptTransfer(transferId);
      state = const TransferActionState.success();
    } catch (e) {
      state = TransferActionState.error(e.toString());
      rethrow;
    }
  }

  /// 전환 요청 거절
  Future<void> rejectTransfer(String transferId) async {
    state = const TransferActionState.loading();
    try {
      await _repository.rejectTransfer(transferId);
      state = const TransferActionState.success();
    } catch (e) {
      state = TransferActionState.error(e.toString());
      rethrow;
    }
  }

  /// 전환 요청 취소
  Future<void> cancelTransfer(String transferId) async {
    state = const TransferActionState.loading();
    try {
      await _repository.cancelTransfer(transferId);
      state = const TransferActionState.success();
    } catch (e) {
      state = TransferActionState.error(e.toString());
      rethrow;
    }
  }

  /// 상태 초기화
  void reset() {
    state = const TransferActionState.idle();
  }
}

/// 트레이너 전환 관리 Provider
final trainerTransferNotifierProvider =
    NotifierProvider<TrainerTransferNotifier, TransferActionState>(() {
  return TrainerTransferNotifier();
});
