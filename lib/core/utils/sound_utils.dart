import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PAL 사운드 피드백 유틸리티
///
/// 운동 완료, 기록 저장 등 주요 이벤트에 사운드 피드백을 제공합니다.
/// 설정에서 ON/OFF 가능합니다.
abstract class SoundUtils {
  SoundUtils._();

  static const String _prefKey = 'sound_enabled';
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// 초기화 (앱 시작 시 한 번 호출)
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_prefKey) ?? true;
      _isInitialized = true;
    } catch (e) {
      debugPrint('[Sound] 초기화 실패: $e');
    }
  }

  /// 사운드 활성화 여부
  static bool get isEnabled => _isEnabled;

  /// 사운드 ON/OFF 설정
  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (e) {
      debugPrint('[Sound] 설정 저장 실패: $e');
    }
  }

  /// 성공음 재생 (운동 완료, 목표 달성)
  static Future<void> playSuccess() async {
    if (!_isEnabled) return;
    // TODO: audioplayers로 assets/sounds/success.mp3 재생
    debugPrint('[Sound] 성공음 재생');
  }

  /// 확인음 재생 (기록 저장, 설정 변경)
  static Future<void> playConfirm() async {
    if (!_isEnabled) return;
    // TODO: audioplayers로 assets/sounds/confirm.mp3 재생
    debugPrint('[Sound] 확인음 재생');
  }

  /// 경고음 재생 (에러, 삭제)
  static Future<void> playWarning() async {
    if (!_isEnabled) return;
    // TODO: audioplayers로 assets/sounds/warning.mp3 재생
    debugPrint('[Sound] 경고음 재생');
  }
}
