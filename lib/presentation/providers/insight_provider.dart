/// 인사이트 Provider
///
/// AI 인사이트 상태 관리 및 데이터 접근을 위한 Provider
/// InsightsService, InsightsGenerationNotifier 포함
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/constants/api_constants.dart';
import 'package:flutter_pal_app/core/constants/firestore_constants.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import 'package:flutter_pal_app/data/repositories/insight_repository.dart';
import 'package:flutter_pal_app/data/services/ai_service.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/data/repositories/base_repository.dart';

// ============================================================================
// 기본 Providers
// ============================================================================

/// 현재 트레이너 ID Provider
final currentTrainerIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.trainerModel?.id;
});

// ============================================================================
// Family Providers (trainerId 매개변수 필요)
// ============================================================================

/// 트레이너 인사이트 목록 스트림 Provider (family)
///
/// 특정 트레이너의 인사이트를 실시간으로 구독
final trainerInsightsStreamProvider =
    StreamProvider.family<List<InsightModel>, String>((ref, trainerId) {
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchTrainerInsights(trainerId);
});

/// 읽지 않은 인사이트 개수 스트림 Provider (family)
final unreadInsightsCountProvider =
    StreamProvider.family<int, String>((ref, trainerId) {
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId.isEmpty) {
    return Stream.value(0);
  }

  return repository.watchUnreadCount(trainerId);
});

/// 높은 우선순위 인사이트 Provider (family)
final highPriorityInsightsProvider =
    Provider.family<List<InsightModel>, String>((ref, trainerId) {
  final insightsAsync = ref.watch(trainerInsightsStreamProvider(trainerId));

  return insightsAsync.when(
    data: (insights) =>
        insights.where((i) => i.priority == InsightPriority.high).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// 회원별 인사이트 Provider (family)
final memberInsightsProvider =
    FutureProvider.family<List<InsightModel>, String>((ref, memberId) async {
  final repository = ref.watch(insightRepositoryProvider);

  if (memberId.isEmpty) {
    return [];
  }

  return repository.getInsightsByMember(memberId);
});

/// 인사이트 유형별 조회 Provider (family)
final insightsByTypeProvider =
    FutureProvider.family<List<InsightModel>, ({String trainerId, InsightType type})>(
  (ref, params) async {
    final repository = ref.watch(insightRepositoryProvider);

    if (params.trainerId.isEmpty) {
      return [];
    }

    return repository.getInsightsByType(params.trainerId, params.type);
  },
);

// ============================================================================
// 현재 로그인된 트레이너 기반 Providers (편의용)
// ============================================================================

/// 현재 트레이너의 인사이트 목록 Provider (실시간)
final trainerInsightsProvider = StreamProvider<List<InsightModel>>((ref) {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId == null || trainerId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchTrainerInsights(trainerId);
});

/// 현재 트레이너의 읽지 않은 인사이트 개수 Provider
final unreadInsightCountProvider = StreamProvider<int>((ref) {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId == null || trainerId.isEmpty) {
    return Stream.value(0);
  }

  return repository.watchUnreadCount(trainerId);
});

/// 현재 트레이너의 읽지 않은 인사이트 목록 Provider
final unreadInsightsProvider = StreamProvider<List<InsightModel>>((ref) {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId == null || trainerId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchTrainerInsights(trainerId, unreadOnly: true);
});

/// 우선순위별 인사이트 개수 Provider
final insightCountByPriorityProvider =
    Provider<Map<InsightPriority, int>>((ref) {
  final insightsAsync = ref.watch(trainerInsightsProvider);

  return insightsAsync.when(
    data: (insights) {
      final counts = <InsightPriority, int>{};
      for (final priority in InsightPriority.values) {
        counts[priority] = insights.where((i) => i.priority == priority).length;
      }
      return counts;
    },
    loading: () => {},
    error: (_, _) => {},
  );
});

/// 최근 인사이트 (홈 화면용) Provider
/// 최대 5개의 최신 인사이트 반환
final recentInsightsProvider = Provider<List<InsightModel>>((ref) {
  final insightsAsync = ref.watch(trainerInsightsProvider);

  return insightsAsync.when(
    data: (insights) => insights.take(5).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// 긴급 인사이트 (high priority) Provider
final urgentInsightsProvider = Provider<List<InsightModel>>((ref) {
  final insightsAsync = ref.watch(trainerInsightsProvider);

  return insightsAsync.when(
    data: (insights) =>
        insights.where((i) => i.priority == InsightPriority.high).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

// ============================================================================
// InsightsService 클래스
// ============================================================================

/// 인사이트 서비스
///
/// AI 인사이트 생성, 읽음/액션 처리 등의 비즈니스 로직 담당
class InsightsService {
  final AIService _aiService;
  final InsightRepository _repository;

  InsightsService({
    required AIService aiService,
    required InsightRepository repository,
  })  : _aiService = aiService,
        _repository = repository;

  /// AI 인사이트 생성
  ///
  /// [trainerId] 트레이너 ID (필수)
  /// [memberId] 특정 회원만 분석 (선택)
  /// [forceRefresh] 캐시 무시하고 새로 생성
  Future<InsightsResult> generateInsights({
    required String trainerId,
    String? memberId,
    bool forceRefresh = false,
  }) async {
    if (trainerId.isEmpty) {
      return InsightsResult.error(
        errorCode: 'invalid-argument',
        errorMessage: '트레이너 ID가 필요해요',
      );
    }

    return _aiService.generateInsights(
      memberId: memberId,
      forceRefresh: forceRefresh,
      includeAI: true,
    );
  }

  /// 인사이트 읽음 처리
  Future<void> markAsRead(String insightId) async {
    if (insightId.isEmpty) return;
    await _repository.markAsRead(insightId);
  }

  /// 모든 인사이트 읽음 처리
  Future<void> markAllAsRead(String trainerId) async {
    if (trainerId.isEmpty) return;
    await _repository.markAllAsRead(trainerId);
  }

  /// 액션 완료 처리
  Future<void> markActionTaken(String insightId) async {
    if (insightId.isEmpty) return;
    await _repository.markActionTaken(insightId);
  }

  /// 만료된 인사이트 삭제
  Future<void> deleteExpiredInsights(String trainerId) async {
    if (trainerId.isEmpty) return;
    await _repository.deleteExpiredInsights(trainerId);
  }

  /// 특정 인사이트 삭제
  Future<void> deleteInsight(String insightId) async {
    if (insightId.isEmpty) return;
    await _repository.deleteInsight(insightId);
  }
}

/// InsightsService Provider
final insightsServiceProvider = Provider<InsightsService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final repository = ref.watch(insightRepositoryProvider);

  return InsightsService(
    aiService: aiService,
    repository: repository,
  );
});

// ============================================================================
// InsightsGenerationNotifier (StateNotifier)
// ============================================================================

/// 인사이트 생성 상태
class InsightsGenerationState {
  /// 로딩 중 여부
  final bool isLoading;

  /// 생성 성공 여부
  final bool isSuccess;

  /// 에러 메시지
  final String? errorMessage;

  /// 마지막 생성 시각
  final DateTime? lastGenerated;

  /// 생성 결과
  final InsightsResult? result;

  const InsightsGenerationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.lastGenerated,
    this.result,
  });

  /// 초기 상태
  factory InsightsGenerationState.initial() {
    return const InsightsGenerationState();
  }

  /// 로딩 상태
  factory InsightsGenerationState.loading() {
    return const InsightsGenerationState(isLoading: true);
  }

  /// 성공 상태
  factory InsightsGenerationState.success(InsightsResult result) {
    return InsightsGenerationState(
      isLoading: false,
      isSuccess: true,
      lastGenerated: DateTime.now(),
      result: result,
    );
  }

  /// 에러 상태
  factory InsightsGenerationState.error(String message) {
    return InsightsGenerationState(
      isLoading: false,
      isSuccess: false,
      errorMessage: message,
    );
  }

  /// 상태 복사
  InsightsGenerationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    DateTime? lastGenerated,
    InsightsResult? result,
  }) {
    return InsightsGenerationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      result: result ?? this.result,
    );
  }
}

/// 인사이트 생성 Notifier
///
/// AI 인사이트 생성 요청 및 상태 관리
class InsightsGenerationNotifier extends Notifier<InsightsGenerationState> {
  @override
  InsightsGenerationState build() {
    return InsightsGenerationState.initial();
  }

  /// AI 인사이트 생성 요청
  ///
  /// [trainerId] 트레이너 ID (필수)
  /// [memberId] 특정 회원만 분석 (선택)
  /// [forceRefresh] 캐시 무시하고 새로 생성
  Future<void> generate({
    required String trainerId,
    String? memberId,
    bool forceRefresh = false,
  }) async {
    if (trainerId.isEmpty) {
      state = InsightsGenerationState.error('트레이너 정보가 없어요');
      return;
    }

    state = InsightsGenerationState.loading();

    try {
      final service = ref.read(insightsServiceProvider);
      final result = await service.generateInsights(
        trainerId: trainerId,
        memberId: memberId,
        forceRefresh: forceRefresh,
      );

      if (result.hasError) {
        state = InsightsGenerationState.error(
          result.errorMessage ?? '인사이트 생성에 실패했어요',
        );
      } else {
        state = InsightsGenerationState.success(result);
      }
    } catch (e) {
      debugPrint('InsightsGenerationNotifier.generate error: $e');
      state = InsightsGenerationState.error(
        _formatErrorMessage(e.toString()),
      );
    }
  }

  /// 에러 메시지를 사용자 친화적 메시지로 변환
  String _formatErrorMessage(String rawError) {
    return _formatInsightError(rawError);
  }

  /// 상태 초기화
  void reset() {
    state = InsightsGenerationState.initial();
  }
}

/// InsightsGenerationNotifier Provider
final insightsGenerationProvider =
    NotifierProvider<InsightsGenerationNotifier, InsightsGenerationState>(
  InsightsGenerationNotifier.new,
);

/// 현재 트레이너용 인사이트 생성 편의 Provider
/// 상태만 watch하고 싶을 때 사용
final currentTrainerInsightsGenerationStateProvider =
    Provider<InsightsGenerationState>((ref) {
  return ref.watch(insightsGenerationProvider);
});

// ============================================================================
// Legacy Providers (하위 호환성)
// ============================================================================

/// AI 인사이트 생성 Provider (Legacy - 하위 호환성)
@Deprecated('insightsGenerationProvider 또는 InsightsService 사용 권장')
final generateInsightsProvider = FutureProvider<InsightsResult>((ref) async {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.generateInsights(includeAI: true);
});

/// 모든 인사이트 읽음 처리 Provider (Legacy)
@Deprecated('InsightsService.markAllAsRead() 사용 권장')
final markAllInsightsAsReadProvider = FutureProvider<void>((ref) async {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId == null || trainerId.isEmpty) {
    return;
  }

  await repository.markAllAsRead(trainerId);
});

/// 만료된 인사이트 삭제 Provider (Legacy)
@Deprecated('InsightsService.deleteExpiredInsights() 사용 권장')
final deleteExpiredInsightsProvider = FutureProvider<void>((ref) async {
  final trainerId = ref.watch(currentTrainerIdProvider);
  final repository = ref.watch(insightRepositoryProvider);

  if (trainerId == null || trainerId.isEmpty) {
    return;
  }

  await repository.deleteExpiredInsights(trainerId);
});

// ============================================================
// 회원용 인사이트 Providers
// ============================================================

/// 회원 인사이트 모델 (회원용)
class MemberInsight {
  final String id;
  final String memberId;
  final String type; // weight, workout, attendance, nutrition, motivation
  final String title;
  final String message;
  final String priority; // high, medium, low
  final bool isRead;
  final DateTime createdAt;
  final DateTime? expiresAt;

  /// 미니 그래프용 데이터 포인트
  /// line: [{value: 75.5, isPrediction: false}, ...]
  /// bar: [{label: '월', value: 3}, ...]
  /// donut: [{name: '단백질', value: 75}, ...]
  /// progress: [{value: 92, max: 100}]
  final List<Map<String, dynamic>>? graphData;

  /// 그래프 타입: 'line', 'bar', 'donut', 'progress'
  final String? graphType;

  const MemberInsight({
    required this.id,
    required this.memberId,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    this.isRead = false,
    required this.createdAt,
    this.expiresAt,
    this.graphData,
    this.graphType,
  });

  factory MemberInsight.fromJson(Map<String, dynamic> json) {
    return MemberInsight(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      priority: json['priority'] as String? ?? 'low',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? (json['expiresAt'] is Timestamp
              ? (json['expiresAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['expiresAt'].toString()))
          : null,
      graphData: json['graphData'] != null
          ? (json['graphData'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
          : null,
      graphType: json['graphType'] as String?,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFF04452);
      case 'medium':
        return const Color(0xFFFF8A00);
      case 'low':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'weight':
        return Icons.monitor_weight;
      case 'workout':
        return Icons.fitness_center;
      case 'attendance':
        return Icons.calendar_today;
      case 'nutrition':
        return Icons.restaurant;
      case 'motivation':
        return Icons.emoji_events;
      default:
        return Icons.lightbulb;
    }
  }
}

/// 회원 인사이트 스트림 Provider
final memberInsightsStreamProvider =
    StreamProvider.family<List<MemberInsight>, String>((ref, memberId) {
  final firestore = ref.watch(firestoreProvider);
  final now = DateTime.now();

  return firestore
      .collection(FirestoreCollections.memberInsights)
      .where('memberId', isEqualTo: memberId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => MemberInsight.fromJson({...doc.data(), 'id': doc.id}))
        .where((insight) =>
            insight.expiresAt == null || insight.expiresAt!.isAfter(now))
        .toList();
  });
});

/// 회원 인사이트 Future Provider (일회성)
final memberInsightsFutureProvider =
    FutureProvider.family<List<MemberInsight>, String>((ref, memberId) async {
  final firestore = ref.watch(firestoreProvider);
  final now = DateTime.now();

  final snapshot = await firestore
      .collection(FirestoreCollections.memberInsights)
      .where('memberId', isEqualTo: memberId)
      .orderBy('createdAt', descending: true)
      .limit(10)
      .get();

  return snapshot.docs
      .map((doc) => MemberInsight.fromJson({...doc.data(), 'id': doc.id}))
      .where((insight) =>
          insight.expiresAt == null || insight.expiresAt!.isAfter(now))
      .toList();
});

/// 회원 인사이트 생성 서비스 Provider
final memberInsightsServiceProvider = Provider<MemberInsightsService>((ref) {
  return MemberInsightsService(
    functions: FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
    firestore: ref.watch(firestoreProvider),
  );
});

/// 회원 인사이트 서비스
class MemberInsightsService {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  MemberInsightsService({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
  })  : _functions = functions,
        _firestore = firestore;

  /// 회원 인사이트 생성 요청
  Future<List<MemberInsight>> generateInsights(String memberId) async {
    try {
      final callable = _functions.httpsCallable(CloudFunctions.generateMemberInsights);
      final response = await callable.call({'memberId': memberId});

      final data = _deepCast(response.data as Map);
      if (data['success'] != true) {
        throw Exception(data['error'] ?? '인사이트 생성에 실패했어요');
      }

      final insightsList = (data['insights'] as List<dynamic>)
          .map((json) => MemberInsight.fromJson(_deepCast(json as Map)))
          .toList();

      return insightsList;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? '인사이트 생성 중 문제가 생겼어요');
    }
  }

  /// Cloud Functions 응답의 `Map<Object?, Object?>`를 `Map<String, dynamic>`으로 변환
  static Map<String, dynamic> _deepCast(Map map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _deepCast(value));
      } else if (value is List) {
        return MapEntry(key.toString(), value.map((e) {
          if (e is Map) return _deepCast(e);
          return e;
        }).toList());
      }
      return MapEntry(key.toString(), value);
    });
  }

  /// 인사이트 읽음 처리
  Future<void> markAsRead(String insightId) async {
    await _firestore
        .collection(FirestoreCollections.memberInsights)
        .doc(insightId)
        .update({'isRead': true});
  }
}

/// 회원 인사이트 생성 상태
class MemberInsightsGenerationState {
  final bool isGenerating;
  final List<MemberInsight>? insights;
  final String? errorMessage;

  const MemberInsightsGenerationState({
    this.isGenerating = false,
    this.insights,
    this.errorMessage,
  });

  factory MemberInsightsGenerationState.initial() =>
      const MemberInsightsGenerationState();

  MemberInsightsGenerationState copyWith({
    bool? isGenerating,
    List<MemberInsight>? insights,
    String? errorMessage,
  }) {
    return MemberInsightsGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      insights: insights ?? this.insights,
      errorMessage: errorMessage,
    );
  }
}

/// 회원 인사이트 생성 Notifier
class MemberInsightsGenerationNotifier
    extends Notifier<MemberInsightsGenerationState> {
  @override
  MemberInsightsGenerationState build() =>
      MemberInsightsGenerationState.initial();

  Future<void> generate(String memberId) async {
    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final service = ref.read(memberInsightsServiceProvider);
      final insights = await service.generateInsights(memberId);

      state = state.copyWith(
        isGenerating: false,
        insights: insights,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: _formatInsightError(e.toString()),
      );
    }
  }

  void reset() {
    state = MemberInsightsGenerationState.initial();
  }
}

/// 회원 인사이트 생성 Provider
final memberInsightsGenerationProvider = NotifierProvider<
    MemberInsightsGenerationNotifier, MemberInsightsGenerationState>(
  MemberInsightsGenerationNotifier.new,
);

// ============================================================================
// 공통 에러 메시지 포매팅
// ============================================================================

/// 인사이트 에러 메시지를 사용자 친화적으로 변환
String _formatInsightError(String rawError) {
  String message = rawError;
  if (message.startsWith('Exception: ')) {
    message = message.substring('Exception: '.length);
  }

  // Firestore 인덱스 누락
  if (message.contains('FAILED_PRECONDITION') || message.contains('requires an index')) {
    return '서버 설정이 필요해요. 관리자에게 문의해주세요';
  }

  // 서버 내부 에러
  if (message.contains('INTERNAL')) {
    return '서버 연결에 실패했어요. 잠시 후 다시 시도해주세요';
  }

  // 권한 에러
  if (message.contains('PERMISSION_DENIED') || message.contains('UNAUTHENTICATED')) {
    return '권한이 없어요. 다시 로그인해주세요';
  }

  // 타임아웃
  if (message.contains('DEADLINE_EXCEEDED') || message.contains('timeout')) {
    return '요청 시간이 초과됐어요. 잠시 후 다시 시도해주세요';
  }

  // 네트워크 에러
  if (message.contains('UNAVAILABLE') || message.contains('network')) {
    return '네트워크 연결을 확인해주세요';
  }

  // 데이터 부족
  if (message.contains('NOT_FOUND') || message.contains('데이터')) {
    return '분석할 기록이 부족해요. 기록을 더 쌓아보세요';
  }

  // 기타: 기술적 내용이 포함된 긴 메시지는 기본 메시지로 대체
  if (message.length > 50 || message.contains('http') || message.contains('firebase')) {
    return '인사이트 생성 중 문제가 생겼어요. 잠시 후 다시 시도해주세요';
  }

  return message.isNotEmpty ? message : '인사이트 생성 중 문제가 생겼어요';
}
