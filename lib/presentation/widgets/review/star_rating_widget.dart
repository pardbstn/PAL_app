import 'package:flutter/material.dart';

/// 별점 라벨 텍스트 매핑
const Map<int, String> _ratingLabels = {
  1: '매우 나쁨',
  2: '나쁨',
  3: '보통',
  4: '좋음',
  5: '매우 좋음',
};

/// 재사용 가능한 5점 별점 위젯
///
/// 탭 가능한 별점 입력 및 읽기 전용 디스플레이 모드를 지원합니다.
/// 골드/노란색 별을 사용하며 선택적으로 반 별을 지원합니다.
class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 32.0,
    this.color = const Color(0xFFF59E0B),
    this.showLabel = true,
    this.allowHalfRating = false,
    this.readOnly = false,
    this.spacing = 4.0,
  });

  /// 현재 별점 (1-5, 반 별 지원 시 0.5 단위)
  final double rating;

  /// 별점 변경 콜백 (null이면 읽기 전용)
  final ValueChanged<double>? onRatingChanged;

  /// 별 아이콘 크기
  final double size;

  /// 별 색상 (기본: 골드/노란색 #F59E0B)
  final Color color;

  /// 별점 라벨 표시 여부 (예: "매우 좋음")
  final bool showLabel;

  /// 반 별 허용 여부
  final bool allowHalfRating;

  /// 읽기 전용 모드
  final bool readOnly;

  /// 별 사이 간격
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveReadOnly = readOnly || onRatingChanged == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return Padding(
              padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
              child: GestureDetector(
                onTap: effectiveReadOnly
                    ? null
                    : () => _handleTap(starIndex.toDouble()),
                onHorizontalDragUpdate: effectiveReadOnly || !allowHalfRating
                    ? null
                    : (details) => _handleDrag(details, index),
                child: _buildStar(starIndex, effectiveReadOnly),
              ),
            );
          }),
        ),
        if (showLabel && rating > 0) ...[
          const SizedBox(height: 4),
          Text(
            _ratingLabels[rating.round()] ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStar(int starIndex, bool effectiveReadOnly) {
    final isFilled = rating >= starIndex;
    final isHalfFilled = allowHalfRating &&
        rating >= starIndex - 0.5 &&
        rating < starIndex;

    IconData iconData;
    Color iconColor;

    if (isFilled) {
      iconData = Icons.star_rounded;
      iconColor = color;
    } else if (isHalfFilled) {
      iconData = Icons.star_half_rounded;
      iconColor = color;
    } else {
      iconData = Icons.star_outline_rounded;
      iconColor = color.withValues(alpha: 0.3);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: Icon(
        iconData,
        key: ValueKey('$starIndex-$isFilled-$isHalfFilled'),
        size: size,
        color: iconColor,
      ),
    );
  }

  void _handleTap(double value) {
    onRatingChanged?.call(value);
  }

  void _handleDrag(DragUpdateDetails details, int index) {
    final dx = details.localPosition.dx;
    final halfPoint = size / 2;
    final newRating = dx < halfPoint ? index + 0.5 : index + 1.0;
    if (newRating != rating && newRating >= 0.5 && newRating <= 5) {
      onRatingChanged?.call(newRating);
    }
  }
}

/// 컴팩트한 별점 디스플레이 위젯 (평균 평점 표시용)
class CompactStarRating extends StatelessWidget {
  const CompactStarRating({
    super.key,
    required this.rating,
    this.size = 16.0,
    this.color = const Color(0xFFF59E0B),
    this.showRatingText = true,
    this.textStyle,
  });

  /// 평점 (0.0 - 5.0)
  final double rating;

  /// 별 아이콘 크기
  final double size;

  /// 별 색상
  final Color color;

  /// 숫자 평점 표시 여부
  final bool showRatingText;

  /// 평점 텍스트 스타일
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: size,
          color: color,
        ),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: textStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
        ],
      ],
    );
  }
}

/// 전체 별점 디스플레이 (읽기 전용, 5개 별 모두 표시)
class FullStarRatingDisplay extends StatelessWidget {
  const FullStarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.color = const Color(0xFFF59E0B),
    this.spacing = 2.0,
  });

  final double rating;
  final double size;
  final Color color;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = rating >= starIndex;
        final isHalfFilled = rating >= starIndex - 0.5 && rating < starIndex;

        IconData iconData;
        Color iconColor;

        if (isFilled) {
          iconData = Icons.star_rounded;
          iconColor = color;
        } else if (isHalfFilled) {
          iconData = Icons.star_half_rounded;
          iconColor = color;
        } else {
          iconData = Icons.star_outline_rounded;
          iconColor = color.withValues(alpha: 0.3);
        }

        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: Icon(
            iconData,
            size: size,
            color: iconColor,
          ),
        );
      }),
    );
  }
}
