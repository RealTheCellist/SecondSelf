import 'package:flutter/material.dart';

import '../models/prompt_option.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_badge.dart';

class CheckInComposeScreen extends StatefulWidget {
  final PromptOption prompt;
  final List<String> emotions;
  final VoidCallback onBack;
  final void Function({
    required String text,
    required List<String> emotions,
  }) onSubmit;

  const CheckInComposeScreen({
    super.key,
    required this.prompt,
    required this.emotions,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<CheckInComposeScreen> createState() => _CheckInComposeScreenState();
}

class _CheckInComposeScreenState extends State<CheckInComposeScreen> {
  final controller = TextEditingController();
  final selectedEmotions = <String>{};
  bool submitAttempted = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get canSubmit => controller.text.trim().isNotEmpty && selectedEmotions.isNotEmpty;

  void toggleEmotion(String emotion) {
    setState(() {
      if (selectedEmotions.contains(emotion)) {
        selectedEmotions.remove(emotion);
        return;
      }

      if (selectedEmotions.length >= 2) {
        return;
      }

      selectedEmotions.add(emotion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasTextError = submitAttempted && controller.text.trim().isEmpty;
    final hasEmotionError = submitAttempted && selectedEmotions.isEmpty;

    return AppScaffold(
      bottomBar: PrimaryButton(
        label: '이대로 비춰보기',
        onPressed: canSubmit
            ? () {
                setState(() => submitAttempted = true);
                widget.onSubmit(
                  text: controller.text,
                  emotions: selectedEmotions.toList(),
                );
              }
            : () => setState(() => submitAttempted = true),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('이전'),
          ),
          const ProgressBadge(label: '2 / 3'),
          const SizedBox(height: 20),
          Text('오늘의 체크인', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '30초면 충분합니다.',
            style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF74675B)),
          ),
          const SizedBox(height: 24),
          Text('선택한 질문', style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B))),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                widget.prompt.label,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('자유롭게 적어보세요', style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B))),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '떠오르는 그대로 적어보세요',
              filled: true,
              fillColor: const Color(0xFFFFFDF9),
              errorText: hasTextError ? '한두 문장만 적어도 충분합니다' : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '지금 가까운 감정을 골라보세요',
            style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B)),
          ),
          const SizedBox(height: 6),
          Text(
            selectedEmotions.isEmpty
                ? '1개 또는 2개만 선택해도 충분합니다'
                : selectedEmotions.length == 1
                    ? '하나 더 고르거나, 지금 상태로도 충분합니다'
                    : '지금은 감정 2개가 선택되어 있습니다',
            style: textTheme.bodySmall?.copyWith(color: const Color(0xFF74675B)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.emotions.map((emotion) {
              final selected = selectedEmotions.contains(emotion);
              return FilterChip(
                label: Text(emotion),
                selected: selected,
                onSelected: (_) => toggleEmotion(emotion),
              );
            }).toList(),
          ),
          if (hasEmotionError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '감정 태그를 1개 이상 골라주세요',
                style: textTheme.bodySmall?.copyWith(color: const Color(0xFF9D3529)),
              ),
            ),
        ],
      ),
    );
  }
}
