import 'package:flutter/material.dart';

/// AI 커리큘럼 생성 화면
class TrainerCurriculumScreen extends StatelessWidget {
  const TrainerCurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 커리큘럼 생성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 준비 중 안내 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.construction_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '기능 준비 중',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI 커리큘럼 자동 생성 기능을 준비하고 있어요.\n빠른 시일 내에 만나볼 수 있어요!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 미리보기 섹션 (비활성화 상태로 표시)
            Opacity(
              opacity: 0.5,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 1: 회원 정보 입력',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 회원 선택 (비활성화)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '회원 선택',
                        border: OutlineInputBorder(),
                        hintText: '회원을 선택해주세요',
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    const SizedBox(height: 16),

                    // 운동 목표
                    const Text('운동 목표'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(label: const Text('다이어트'), selected: true, onSelected: null),
                        ChoiceChip(label: const Text('벌크업'), selected: false, onSelected: null),
                        ChoiceChip(label: const Text('체력증진'), selected: false, onSelected: null),
                        ChoiceChip(label: const Text('재활'), selected: false, onSelected: null),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 운동 경력
                    const Text('운동 경력'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(label: const Text('초보'), selected: false, onSelected: null),
                        ChoiceChip(label: const Text('중급'), selected: true, onSelected: null),
                        ChoiceChip(label: const Text('고급'), selected: false, onSelected: null),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 생성 회차
                    TextFormField(
                      initialValue: '8',
                      enabled: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '생성 회차',
                        border: OutlineInputBorder(),
                        suffixText: '회',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AI 생성 버튼 (비활성화)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI 커리큘럼 생성하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
