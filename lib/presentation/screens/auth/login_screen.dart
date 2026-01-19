import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/animated_widgets.dart';

/// 로그인 화면
/// 트레이너/회원 선택 후 로그인
/// shimmer 로딩, lottie 애니메이션 적용
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.trainer;
  bool _isPasswordVisible = false;
  bool _isSignUp = false; // 회원가입 모드 토글

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 및 Lottie 애니메이션
                    _buildLogo(context),
                    const SizedBox(height: 8),

                    // 앱 타이틀
                    Text(
                      'PAL',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: 4,
                      ),
                    ).animateSlideDown(delay: const Duration(milliseconds: 100)),

                    Text(
                      '기록하고, 분석하고, 성장하다',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ).animateFadeIn(delay: const Duration(milliseconds: 200)),

                    const SizedBox(height: 40),

                    // 역할 선택 카드
                    _buildRoleSelector(context),
                    const SizedBox(height: 24),

                    // 이메일 입력
                    _buildEmailField(context),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    _buildPasswordField(context),
                    const SizedBox(height: 8),

                    // 에러 메시지
                    if (authState.errorMessage != null)
                      _buildErrorMessage(authState.errorMessage!),

                    const SizedBox(height: 24),

                    // 로그인/회원가입 버튼
                    _buildSubmitButton(context, isLoading),
                    const SizedBox(height: 16),

                    // 구분선
                    _buildDivider(context),
                    const SizedBox(height: 16),

                    // 구글 로그인 버튼
                    _buildGoogleSignInButton(context, isLoading),
                    const SizedBox(height: 24),

                    // 모드 전환 (로그인 <-> 회원가입)
                    _buildModeSwitch(context),

                    // 비밀번호 찾기
                    if (!_isSignUp) _buildForgotPassword(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Lottie 로고 애니메이션
  Widget _buildLogo(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Lottie.network(
        'https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json', // fitness animation
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Lottie 로드 실패 시 기본 아이콘
          return Icon(
            Icons.fitness_center,
            size: 80,
            color: AppTheme.primary,
          );
        },
      ),
    ).animateScaleIn();
  }

  /// 역할 선택 카드
  Widget _buildRoleSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleOption(
              context,
              role: UserRole.trainer,
              icon: Icons.sports,
              label: '트레이너',
            ),
          ),
          Expanded(
            child: _buildRoleOption(
              context,
              role: UserRole.member,
              icon: Icons.person,
              label: '회원',
            ),
          ),
        ],
      ),
    ).animateSlideUp(delay: const Duration(milliseconds: 300));
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required UserRole role,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedRole == role;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이메일 입력 필드
  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: '이메일',
        hintText: 'email@example.com',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return '올바른 이메일 형식이 아닙니다';
        }
        return null;
      },
    ).animateSlideUp(delay: const Duration(milliseconds: 400));
  }

  /// 비밀번호 입력 필드
  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSubmit(),
      decoration: InputDecoration(
        labelText: '비밀번호',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        if (_isSignUp && value.length < 6) {
          return '비밀번호는 6자 이상이어야 합니다';
        }
        return null;
      },
    ).animateSlideUp(delay: const Duration(milliseconds: 500));
  }

  /// 에러 메시지
  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.error, fontSize: 14),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 300.ms);
  }

  /// 로그인/회원가입 버튼
  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? _buildLoadingState()
            : Text(
                _isSignUp ? '회원가입' : '로그인',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ).animateSlideUp(delay: const Duration(milliseconds: 600));
  }

  /// 로딩 상태 위젯 (LoadingDots 사용)
  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const LoadingDots(
          color: Colors.white,
          size: 8,
        ),
        const SizedBox(width: 12),
        Text(
          _isSignUp ? '가입 중...' : '로그인 중...',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  /// 구분선
  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  /// 구글 로그인 버튼
  Widget _buildGoogleSignInButton(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.g_mobiledata,
            size: 24,
          ),
        ),
        label: const Text(
          'Google로 계속하기',
          style: TextStyle(fontSize: 16),
        ),
      ),
    ).animateSlideUp(delay: const Duration(milliseconds: 700));
  }

  /// 로그인/회원가입 모드 전환
  Widget _buildModeSwitch(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? '이미 계정이 있으신가요?' : '아직 계정이 없으신가요?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() => _isSignUp = !_isSignUp);
          },
          child: Text(
            _isSignUp ? '로그인' : '회원가입',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// 비밀번호 찾기
  Widget _buildForgotPassword(BuildContext context) {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: Text(
        '비밀번호를 잊으셨나요?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// 로그인/회원가입 처리
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signUpWithEmail(
              _emailController.text,
              _passwordController.text,
              _selectedRole,
            );
      } else {
        await ref.read(authProvider.notifier).signInWithEmail(
              _emailController.text,
              _passwordController.text,
              _selectedRole,
            );
      }
      // 로그인 성공 시 go_router의 redirect가 자동으로 처리
    } catch (e) {
      // 에러는 authState.errorMessage로 표시됨
    }
  }

  /// 구글 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle(_selectedRole);
    } catch (e) {
      // 에러는 authState.errorMessage로 표시됨
    }
  }

  /// 비밀번호 찾기 처리
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 먼저 입력해주세요')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호 재설정 이메일을 전송했습니다')),
        );
      }
    } catch (e) {
      // 에러는 authState.errorMessage로 표시됨
    }
  }
}
