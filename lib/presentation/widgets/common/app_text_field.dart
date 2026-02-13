import 'package:flutter/material.dart';

/// PAL 앱 공통 텍스트 필드 위젯
///
/// Label이 필드 위에 표시되고, 에러/포커스 상태에 따라
/// 테두리 색상이 변경되는 커스텀 텍스트 필드
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.validator,
  });

  /// 필드 위에 표시되는 라벨 텍스트
  final String? label;

  /// 필드 내부 힌트 텍스트
  final String? hint;

  /// 에러 메시지 (표시되면 빨간 테두리)
  final String? errorText;

  /// 텍스트 컨트롤러
  final TextEditingController? controller;

  /// 비밀번호 숨김 여부
  final bool obscureText;

  /// 키보드 타입
  final TextInputType? keyboardType;

  /// 왼쪽 아이콘
  final IconData? prefixIcon;

  /// 오른쪽 위젯 (예: 비밀번호 표시 토글 버튼)
  final Widget? suffix;

  /// 최대 줄 수 (null이면 무제한)
  final int? maxLines;

  /// 활성화 여부
  final bool enabled;

  /// 텍스트 변경 콜백
  final ValueChanged<String>? onChanged;

  /// Form 유효성 검사기
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;

    // 테두리 색상 설정 (Toss Design System)
    final defaultBorderColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD9D9D9);
    final focusedBorderColor = const Color(0xFF0064FF); // Toss Blue
    final errorBorderColor = const Color(0xFFF04452); // Toss Red

    // 비활성화 배경색
    final disabledFillColor = isDark ? Colors.grey[800] : Colors.grey[200];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 (필드 위에 표시)
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: hasError
                  ? const Color(0xFFF04452)
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 텍스트 필드
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          onChanged: onChanged,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white : null,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFFB0B0B0),
            ),
            filled: !enabled,
            fillColor: !enabled ? disabledFillColor : null,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: hasError
                        ? const Color(0xFFF04452)
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  )
                : null,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 14,
            ),
            // 기본 테두리 (Toss Design System - UnderlineInputBorder)
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: defaultBorderColor,
                width: 1,
              ),
            ),
            // 활성화 테두리
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? errorBorderColor : defaultBorderColor,
                width: hasError ? 1.5 : 1,
              ),
            ),
            // 포커스 테두리
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? errorBorderColor : focusedBorderColor,
                width: 2,
              ),
            ),
            // 에러 테두리
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: errorBorderColor,
                width: 1.5,
              ),
            ),
            // 포커스 + 에러 테두리
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: errorBorderColor,
                width: 2,
              ),
            ),
            // 비활성화 테두리
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD9D9D9),
                width: 1,
              ),
            ),
            // validator 에러 텍스트는 숨김 (커스텀 에러 텍스트 사용)
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),

        // 에러 메시지 (필드 아래 표시)
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: const Color(0xFFF04452),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFF04452),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
