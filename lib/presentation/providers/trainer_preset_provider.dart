import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_preset_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_preset_repository.dart';

/// 트레이너 프리셋 조회 Provider
final trainerPresetProvider =
    FutureProvider.family<TrainerPresetModel?, String>((ref, trainerId) async {
  final repo = ref.watch(trainerPresetRepositoryProvider);
  return await repo.getByTrainerId(trainerId);
});

/// 트레이너 프리셋 저장 Notifier
class TrainerPresetNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 프리셋 저장/업데이트
  Future<bool> savePreset(TrainerPresetModel preset) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(trainerPresetRepositoryProvider);
      await repo.createOrUpdate(preset);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

/// Provider
final trainerPresetNotifierProvider =
    NotifierProvider<TrainerPresetNotifier, AsyncValue<void>>(
  TrainerPresetNotifier.new,
);
