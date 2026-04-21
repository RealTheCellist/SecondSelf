import 'package:flutter/material.dart';

import '../models/prompt_option.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_badge.dart';

class QuestionSelectScreen extends StatelessWidget {
  final List<PromptOption> prompts;
  final ValueChanged<PromptOption> onSelected;

  const QuestionSelectScreen({
    super.key,
    required this.prompts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionSelectBody(
      prompts: prompts,
      onSelected: onSelected,
    );
  }
}

class _QuestionSelectBody extends StatefulWidget {
  final List<PromptOption> prompts;
  final ValueChanged<PromptOption> onSelected;

  const _QuestionSelectBody({
    required this.prompts,
    required this.onSelected,
  });

  @override
  State<_QuestionSelectBody> createState() => _QuestionSelectBodyState();
}

class _QuestionSelectBodyState extends State<_QuestionSelectBody> {
  PromptOption? selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      bottomBar: PrimaryButton(
        label: '시작하기',
        onPressed: selected == null ? null : () => widget.onSelected(selected!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgressBadge(label: '1 / 3'),
          const SizedBox(height: 20),
          Text(
            'Second Self',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 28),
          Text(
            '오늘의 나는 어디에 가장 오래 머물렀나요?',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '한 가지 질문을 고르고, 짧게 적어보세요.',
            style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF74675B)),
          ),
          const SizedBox(height: 28),
          ...widget.prompts.map(
            (prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => selected = prompt),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          selected?.id == prompt.id
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: const Color(0xFF9D5F3F),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            prompt.label,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
