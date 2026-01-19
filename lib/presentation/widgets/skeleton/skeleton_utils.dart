import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/states.dart';

/// AsyncValue용 스켈레톤 빌더
class AsyncValueSkeleton<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget skeleton;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace? stack)? error;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  const AsyncValueSkeleton({
    super.key,
    required this.asyncValue,
    required this.skeleton,
    required this.data,
    this.error,
    this.empty,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => skeleton,
      error: (err, stack) => error?.call(err, stack) ?? _defaultError(context, err, stack),
      data: (value) {
        if (_checkEmpty(value)) {
          return empty ?? const SizedBox.shrink();
        }
        return data(value);
      },
    );
  }

  bool _checkEmpty(T value) {
    if (isEmpty != null) return isEmpty!(value);
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    if (value == null) return true;
    return false;
  }

  Widget _defaultError(BuildContext context, Object err, StackTrace? stack) {
    return ErrorState.fromError(err);
  }
}

/// 스켈레톤 래퍼 (로딩 상태에 따라 스켈레톤 또는 컨텐츠 표시)
class SkeletonLoader extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;

  const SkeletonLoader({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading ? skeleton : child;
  }
}

/// FutureBuilder용 스켈레톤 래퍼
class FutureSkeleton<T> extends StatelessWidget {
  final Future<T> future;
  final Widget skeleton;
  final Widget Function(T data) builder;
  final Widget Function(Object error)? errorBuilder;

  const FutureSkeleton({
    super.key,
    required this.future,
    required this.skeleton,
    required this.builder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return skeleton;
        }
        if (snapshot.hasError) {
          return errorBuilder?.call(snapshot.error!) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('오류: ${snapshot.error}'),
                ],
              ),
            );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}

/// StreamBuilder용 스켈레톤 래퍼
class StreamSkeleton<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget skeleton;
  final Widget Function(T data) builder;
  final Widget Function(Object error)? errorBuilder;

  const StreamSkeleton({
    super.key,
    required this.stream,
    required this.skeleton,
    required this.builder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return skeleton;
        }
        if (snapshot.hasError) {
          return errorBuilder?.call(snapshot.error!) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('오류: ${snapshot.error}'),
                ],
              ),
            );
        }
        if (!snapshot.hasData) {
          return skeleton;
        }
        return builder(snapshot.data as T);
      },
    );
  }
}
