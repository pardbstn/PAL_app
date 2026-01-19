import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드 Provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

/// 테마 모드 상태 관리
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  /// 저장된 테마 모드 불러오기
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// 다크모드 토글
  void toggleDarkMode(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode();
  }

  /// 테마 모드 설정
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode();
  }

  /// 테마 모드 저장
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.name);
  }

  /// 현재 다크모드 여부
  bool get isDarkMode => state == ThemeMode.dark;
}
