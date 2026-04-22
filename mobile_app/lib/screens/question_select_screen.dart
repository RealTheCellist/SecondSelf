import 'package:flutter/material.dart';

import '../models/prompt_option.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_badge.dart';

class QuestionSelectScreen extends StatelessWidget {
  final List<PromptOption> prompts;
  final PromptOption? recommendedPrompt;
  final ValueChanged<PromptOption> onSelected;

  const QuestionSelectScreen({
    super.key,
    required this.prompts,
    this.recommendedPrompt,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionSelectBody(
      prompts: prompts,
      recommendedPrompt: recommendedPrompt,
      onSelected: onSelected,
    );
  }
}

class _QuestionSelectBody extends StatefulWidget {
  final List<PromptOption> prompts;
  final PromptOption? recommendedPrompt;
  final ValueChanged<PromptOption> onSelected;

  const _QuestionSelectBody({
    required this.prompts,
    this.recommendedPrompt,
    required this.onSelected,
  });

  @override
  State<_QuestionSelectBody> createState() => _QuestionSelectBodyState();
}

class _QuestionSelectBodyState extends State<_QuestionSelectBody> {
  PromptOption? selected;

  Map<PromptCategory, List<PromptOption>> get groupedPrompts {
    final map = <PromptCategory, List<PromptOption>>{};
    for (final prompt in widget.prompts) {
      map.putIfAbsent(prompt.category, () => <PromptOption>[]).add(prompt);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      bottomBar: PrimaryButton(
        label: 'Start',
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
            'Where has your mind been most often today?',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Pick one prompt and write briefly.',
            style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF74675B)),
          ),
          if (widget.recommendedPrompt != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF6EBDD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x339D5F3F)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _categoryIcon(widget.recommendedPrompt!.category),
                        size: 16,
                        color: const Color(0xFF9D5F3F),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Balanced recommendation - ${widget.recommendedPrompt!.category.label}',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7B6450),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recommendedPrompt!.label,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selected = widget.recommendedPrompt;
                        });
                      },
                      child: const Text('Select recommendation'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'All prompts (${widget.prompts.length})',
                style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAllPrompts(context),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...groupedPrompts.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcon(entry.key),
                          size: 16,
                          color: const Color(0xFF9D5F3F),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.key.label,
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF74675B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map(
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
            ),
          ),
        ],
      ),
    );
  }

  void _showAllPrompts(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All prompts (${widget.prompts.length})',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: groupedPrompts.entries.length,
                    itemBuilder: (context, index) {
                      final categoryEntry = groupedPrompts.entries.elementAt(index);
                      final category = categoryEntry.key;
                      final prompts = categoryEntry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    _categoryIcon(category),
                                    size: 15,
                                    color: const Color(0xFF9D5F3F),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category.label,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF74675B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...prompts.map((prompt) {
                              final globalIndex = widget.prompts.indexOf(prompt) + 1;
                              final isSelected = selected?.id == prompt.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      setState(() {
                                        selected = prompt;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFF1E2D3)
                                            : const Color(0xFFFDF7EF),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0x559D5F3F)
                                              : const Color(0x22311F10),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            size: 18,
                                            color: const Color(0xFF9D5F3F),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '$globalIndex. ${prompt.label}',
                                              style: textTheme.bodyLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(PromptCategory category) {
    switch (category) {
      case PromptCategory.selfAwareness:
        return Icons.psychology_alt_outlined;
      case PromptCategory.emotion:
        return Icons.favorite_border;
      case PromptCategory.relationship:
        return Icons.people_alt_outlined;
      case PromptCategory.growth:
        return Icons.trending_up;
    }
  }
}
