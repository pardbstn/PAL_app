import 'package:flutter/material.dart';

/// AI 커리큘럼 생성 화면
class TrainerCurriculumScreen extends StatelessWidget {
  const TrainerCurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 커리큘럼 생성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1: 회원 정보 입력',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // 회원 선택
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '회원 선택',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('김민수')),
                DropdownMenuItem(value: '2', child: Text('이수진')),
                DropdownMenuItem(value: '3', child: Text('박지영')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),

            // 운동 목표
            const Text('운동 목표'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('다이어트'), selected: true, onSelected: (_) {}),
                ChoiceChip(label: const Text('벌크업'), selected: false, onSelected: (_) {}),
                ChoiceChip(label: const Text('체력증진'), selected: false, onSelected: (_) {}),
                ChoiceChip(label: const Text('재활'), selected: false, onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),

            // 운동 경력
            const Text('운동 경력'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('초보'), selected: false, onSelected: (_) {}),
                ChoiceChip(label: const Text('중급'), selected: true, onSelected: (_) {}),
                ChoiceChip(label: const Text('고급'), selected: false, onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),

            // 생성 회차
            TextFormField(
              initialValue: '8',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '생성 회차',
                border: OutlineInputBorder(),
                suffixText: '회',
              ),
            ),
            const SizedBox(height: 24),

            // AI 생성 버튼
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: AI 커리큘럼 생성 요청
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI 커리큘럼 생성하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
