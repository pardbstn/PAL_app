import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/constants/exercise_constants.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_repository.dart';

/// 커리큘럼 V2 생성 상태
enum CurriculumGeneratorStatus { idle, loading, generated, error }

class CurriculumGeneratorV2State {
  final CurriculumGeneratorStatus status;
  final List<List<Exercise>> sessions; // 다중 회차
  final int currentSessionIndex;
  final List<String> sessionNotes; // 회차별 AI 노트
  final String? error;

  const CurriculumGeneratorV2State({
    this.status = CurriculumGeneratorStatus.idle,
    this.sessions = const [],
    this.currentSessionIndex = 0,
    this.sessionNotes = const [],
    this.error,
  });

  /// 현재 회차의 운동 목록
  List<Exercise> get currentExercises =>
      currentSessionIndex < sessions.length ? sessions[currentSessionIndex] : [];

  /// 현재 회차의 총 세트수
  int get totalSets => currentExercises.fold<int>(0, (sum, e) => sum + e.sets);

  /// 현재 회차의 예상 소요 시간 (분)
  int get estimatedDuration => currentExercises.fold<int>(0, (sum, e) {
        final restPerSet = (e.restSeconds ?? 60);
        return sum + (e.sets * (120 + restPerSet) ~/ 60);
      });

  /// 현재 회차의 AI 노트
  String get currentNotes =>
      currentSessionIndex < sessionNotes.length ? sessionNotes[currentSessionIndex] : '';

  /// 총 회차 수
  int get sessionCount => sessions.length;

  CurriculumGeneratorV2State copyWith({
    CurriculumGeneratorStatus? status,
    List<List<Exercise>>? sessions,
    int? currentSessionIndex,
    List<String>? sessionNotes,
    String? error,
  }) {
    return CurriculumGeneratorV2State(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      currentSessionIndex: currentSessionIndex ?? this.currentSessionIndex,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      error: error,
    );
  }
}

/// 커리큘럼 V2 생성 Notifier
class CurriculumGeneratorV2Notifier
    extends Notifier<CurriculumGeneratorV2State> {
  @override
  CurriculumGeneratorV2State build() => const CurriculumGeneratorV2State();

  /// AI 커리큘럼 생성 (다중 회차)
  Future<void> generate({
    required String memberId,
    String? trainerId,
    required CurriculumSettings settings,
    List<String> excludedExerciseIds = const [],
  }) async {
    state = state.copyWith(status: CurriculumGeneratorStatus.loading, error: null);

    try {
      final sessionCount = settings.sessionCount;
      final allSessions = <List<Exercise>>[];
      final allNotes = <String>[];

      for (int i = 0; i < sessionCount; i++) {
        final exercises = _generateSessionExercises(
          settings: settings,
          excludedExerciseIds: excludedExerciseIds,
          sessionIndex: i,
          totalSessions: sessionCount,
        );

        if (exercises.isEmpty && i == 0) {
          state = state.copyWith(
            status: CurriculumGeneratorStatus.error,
            error: '조건에 맞는 운동을 찾을 수 없습니다. 설정을 변경해주세요.',
          );
          return;
        }

        allSessions.add(exercises);
        allNotes.add(_generateSessionNote(settings, exercises, i + 1));
      }

      state = state.copyWith(
        status: CurriculumGeneratorStatus.generated,
        sessions: allSessions,
        sessionNotes: allNotes,
        currentSessionIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: CurriculumGeneratorStatus.error,
        error: '커리큘럼 생성에 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// 현재 회차 변경
  void setCurrentSession(int index) {
    if (index >= 0 && index < state.sessions.length) {
      state = state.copyWith(currentSessionIndex: index);
    }
  }

  /// 현재 회차에 운동 추가
  void addExercise(Exercise exercise) {
    final sessions = List<List<Exercise>>.from(state.sessions);
    final current = List<Exercise>.from(sessions[state.currentSessionIndex]);
    current.add(exercise);
    sessions[state.currentSessionIndex] = current;
    state = state.copyWith(sessions: sessions);
  }

  /// 현재 회차에서 운동 삭제
  void removeExercise(int index) {
    final sessions = List<List<Exercise>>.from(state.sessions);
    final current = List<Exercise>.from(sessions[state.currentSessionIndex]);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      sessions[state.currentSessionIndex] = current;
      state = state.copyWith(sessions: sessions);
    }
  }

  /// 운동 교체
  void replaceExercise(int index, Exercise newExercise) {
    final sessions = List<List<Exercise>>.from(state.sessions);
    final current = List<Exercise>.from(sessions[state.currentSessionIndex]);
    if (index >= 0 && index < current.length) {
      current[index] = newExercise.copyWith(isModifiedByTrainer: true);
      sessions[state.currentSessionIndex] = current;
      state = state.copyWith(sessions: sessions);
    }
  }

  /// 운동 수정 (세트/렙/휴식)
  void updateExercise(int index, {int? sets, int? reps, int? restSeconds}) {
    final sessions = List<List<Exercise>>.from(state.sessions);
    final current = List<Exercise>.from(sessions[state.currentSessionIndex]);
    if (index >= 0 && index < current.length) {
      final exercise = current[index];
      current[index] = exercise.copyWith(
        sets: sets ?? exercise.sets,
        reps: reps ?? exercise.reps,
        restSeconds: restSeconds ?? exercise.restSeconds,
        isModifiedByTrainer: true,
      );
      sessions[state.currentSessionIndex] = current;
      state = state.copyWith(sessions: sessions);
    }
  }

  /// 전체 커리큘럼 Firestore에 저장
  Future<bool> saveAllCurriculums({
    required String memberId,
    required String trainerId,
    required CurriculumSettings settings,
  }) async {
    try {
      final repo = ref.read(curriculumRepositoryProvider);
      final startSession = await repo.getNextSessionNumber(memberId);

      for (int i = 0; i < state.sessions.length; i++) {
        final focusLabel = _getSessionFocusLabel(settings, i, state.sessions.length);
        final curriculum = CurriculumModel(
          id: '',
          memberId: memberId,
          trainerId: trainerId,
          sessionNumber: startSession + i,
          title: '${i + 1}회차 $focusLabel',
          exercises: state.sessions[i],
          isAiGenerated: true,
          settings: settings,
          aiNotes: i < state.sessionNotes.length ? state.sessionNotes[i] : '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repo.create(curriculum);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: '저장에 실패했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 회차별 운동 생성
  List<Exercise> _generateSessionExercises({
    required CurriculumSettings settings,
    required List<String> excludedExerciseIds,
    required int sessionIndex,
    required int totalSessions,
  }) {
    final random = Random();
    final exerciseCount = settings.exerciseCount;
    final setCount = settings.setCount;
    final excludedParts = settings.excludedParts;

    // 이 회차에서 집중할 부위 결정
    final sessionFocusParts = _getSessionFocusParts(
      settings.focusParts,
      sessionIndex,
      totalSessions,
    );

    // 전체 운동 중 제외 운동/부위 필터링
    var candidates = ExerciseConstants.exercises.where((ex) {
      final id = ex['id']?.toString() ?? '';
      final muscle = ex['primaryMuscle']?.toString() ?? '';

      if (excludedExerciseIds.contains(id)) return false;

      if (excludedParts.isNotEmpty) {
        final injuryMap = _getInjuryMuscleMap();
        for (final part in excludedParts) {
          final affected = injuryMap[part] ?? [];
          if (affected.contains(muscle)) return false;
        }
      }

      return true;
    }).toList();

    List<Map<String, dynamic>> selected = [];

    if (sessionFocusParts.isNotEmpty) {
      final perPart = (exerciseCount / sessionFocusParts.length).ceil();
      for (final part in sessionFocusParts) {
        final partExercises = candidates
            .where((ex) => ex['primaryMuscle'] == part)
            .toList();
        partExercises.shuffle(random);
        selected.addAll(partExercises.take(perPart));
      }
    } else {
      candidates.shuffle(random);
      selected = candidates.take(exerciseCount * 2).toList();
    }

    // 중복 제거
    final uniqueIds = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final ex in selected) {
      final id = ex['id']?.toString() ?? '';
      if (!uniqueIds.contains(id)) {
        uniqueIds.add(id);
        unique.add(ex);
      }
    }

    final finalList = unique.take(exerciseCount).toList();

    // Exercise 모델로 변환
    return finalList.map((ex) {
      int reps = 10;
      int restSeconds = 60;

      if (settings.styles.contains('고중량') || settings.styles.contains('스트렝스')) {
        reps = 5;
        restSeconds = 120;
      } else if (settings.styles.contains('저중량') || settings.styles.contains('고반복') || settings.styles.contains('근지구력')) {
        reps = 15;
        restSeconds = 45;
      } else if (settings.styles.contains('근비대')) {
        reps = 10;
        restSeconds = 90;
      } else if (settings.styles.contains('서킷')) {
        reps = 12;
        restSeconds = 30;
      }

      return Exercise(
        name: ex['nameKo']?.toString() ?? '',
        sets: setCount,
        reps: reps,
        restSeconds: restSeconds,
        exerciseId: ex['id']?.toString(),
      );
    }).toList();
  }

  /// 회차별 집중 부위 결정 (로테이션)
  List<String> _getSessionFocusParts(
    List<String> focusParts,
    int sessionIndex,
    int totalSessions,
  ) {
    if (focusParts.isEmpty) {
      // 기본 분할: 가슴+삼두, 등+이두, 하체+어깨, 전신
      const defaultSplits = [
        ['가슴', '팔'],
        ['등', '팔'],
        ['하체', '어깨'],
        ['가슴', '등'],
        ['하체', '복근'],
      ];
      return defaultSplits[sessionIndex % defaultSplits.length];
    }

    if (focusParts.contains('전신')) {
      // 전신이면 모든 부위에서 골고루 선택
      const allParts = ['가슴', '등', '하체', '어깨', '팔', '복근'];
      // 회차마다 다른 조합으로 2-3개 부위 선택
      final startIdx = (sessionIndex * 2) % allParts.length;
      return [
        allParts[startIdx % allParts.length],
        allParts[(startIdx + 1) % allParts.length],
        allParts[(startIdx + 2) % allParts.length],
      ];
    }

    if (focusParts.length == 1) {
      // 부위가 하나면 매 회차 같은 부위
      return focusParts;
    }

    // 여러 부위면 로테이션
    if (totalSessions <= focusParts.length) {
      return [focusParts[sessionIndex % focusParts.length]];
    }

    // 세션이 부위보다 많으면 1-2개씩 로테이션
    final idx = sessionIndex % focusParts.length;
    return [focusParts[idx]];
  }

  /// 회차의 집중 부위 라벨
  String _getSessionFocusLabel(CurriculumSettings settings, int sessionIndex, int totalSessions) {
    final parts = _getSessionFocusParts(settings.focusParts, sessionIndex, totalSessions);
    if (parts.isEmpty) return '운동';
    return parts.join('/');
  }

  /// 회차별 AI 노트 생성
  String _generateSessionNote(CurriculumSettings settings, List<Exercise> exercises, int sessionNum) {
    final parts = <String>[];
    parts.add('${sessionNum}회차');

    final focusMuscles = exercises
        .map((e) {
          final match = ExerciseConstants.exercises.firstWhere(
            (ex) => ex['id'] == e.exerciseId,
            orElse: () => <String, dynamic>{},
          );
          return match['primaryMuscle']?.toString() ?? '';
        })
        .where((m) => m.isNotEmpty)
        .toSet();

    if (focusMuscles.isNotEmpty) {
      parts.add('부위: ${focusMuscles.join(', ')}');
    }
    if (settings.styles.isNotEmpty) {
      parts.add('스타일: ${settings.styles.join(', ')}');
    }
    parts.add('${exercises.length}종목');

    return parts.join(' | ');
  }

  Map<String, List<String>> _getInjuryMuscleMap() {
    return {
      '어깨': ['어깨', '가슴'],
      '허리': ['등', '하체', '전신'],
      '무릎': ['하체'],
      '손목': ['팔', '가슴'],
      '발목': ['하체', '전신'],
      '목': ['어깨', '등'],
      '팔꿈치': ['팔', '가슴'],
      '고관절': ['하체', '전신'],
    };
  }

  /// 상태 초기화
  void reset() {
    state = const CurriculumGeneratorV2State();
  }
}

/// Provider
final curriculumGeneratorV2Provider = NotifierProvider<
    CurriculumGeneratorV2Notifier, CurriculumGeneratorV2State>(
  CurriculumGeneratorV2Notifier.new,
);
