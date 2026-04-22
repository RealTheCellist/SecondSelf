import 'package:flutter/material.dart';

import '../data/sample_checkins.dart';
import '../models/checkin.dart';
import '../models/prompt_option.dart';
import '../screens/checkin_compose_screen.dart';
import '../screens/question_select_screen.dart';
import '../screens/reflection_feed_screen.dart';
import '../theme/app_theme.dart';
import '../utils/reflection_engine.dart';

class SecondSelfApp extends StatelessWidget {
  const SecondSelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Second Self',
      theme: buildSecondSelfTheme(),
      home: const SecondSelfFlow(),
    );
  }
}

enum FlowStep {
  question,
  compose,
  reflection,
}

class SecondSelfFlow extends StatefulWidget {
  const SecondSelfFlow({super.key});

  @override
  State<SecondSelfFlow> createState() => _SecondSelfFlowState();
}

class _SecondSelfFlowState extends State<SecondSelfFlow> {
  FlowStep _step = FlowStep.question;
  PromptOption? _selectedPrompt;
  final List<CheckIn> _checkins = [];

  static const prompts = [
    PromptOption(
      id: 'thought',
      label: '요즘 자주 붙잡히는 생각은 무엇인가요?',
      category: PromptCategory.selfAwareness,
    ),
    PromptOption(
      id: 'identity',
      label: '지금의 나를 한 문장으로 표현하면 어떤가요?',
      category: PromptCategory.selfAwareness,
    ),
    PromptOption(
      id: 'energy',
      label: '요즘 내 에너지를 가장 많이 가져가는 건 무엇인가요?',
      category: PromptCategory.selfAwareness,
    ),
    PromptOption(
      id: 'emotion',
      label: '최근 반복해서 느끼는 감정은 무엇인가요?',
      category: PromptCategory.emotion,
    ),
    PromptOption(
      id: 'moment',
      label: '최근에 나를 가장 흔들었던 순간은 언제였나요?',
      category: PromptCategory.emotion,
    ),
    PromptOption(
      id: 'desire',
      label: '요즘 내가 사실은 더 원하고 있는 것은 무엇인가요?',
      category: PromptCategory.emotion,
    ),
    PromptOption(
      id: 'avoidance',
      label: '계속 미루고 있지만 마음에 걸리는 일은 무엇인가요?',
      category: PromptCategory.relationship,
    ),
    PromptOption(
      id: 'boundary',
      label: '지금 내 삶에서 더 분명해져야 할 경계는 무엇인가요?',
      category: PromptCategory.relationship,
    ),
    PromptOption(
      id: 'connection',
      label: '요즘 더 가까워지고 싶거나 멀어지고 싶은 관계는 무엇인가요?',
      category: PromptCategory.relationship,
    ),
    PromptOption(
      id: 'shift',
      label: '한 달 전의 나와 비교해 달라진 점은 무엇인가요?',
      category: PromptCategory.growth,
    ),
    PromptOption(
      id: 'learning',
      label: '최근 내가 새롭게 배운 나의 패턴은 무엇인가요?',
      category: PromptCategory.growth,
    ),
    PromptOption(
      id: 'nextStep',
      label: '지금의 나를 위해 이번 주에 시도해볼 가장 작은 변화는 무엇인가요?',
      category: PromptCategory.growth,
    ),
  ];

  PromptOption? _findPromptById(String promptId) {
    try {
      return prompts.firstWhere((prompt) => prompt.id == promptId);
    } catch (_) {
      return null;
    }
  }

  PromptOption _buildBalancedRecommendation() {
    final countByCategory = <PromptCategory, int>{
      for (final category in PromptCategory.values) category: 0,
    };

    for (final checkin in _checkins) {
      final prompt = _findPromptById(checkin.promptId);
      if (prompt != null) {
        countByCategory[prompt.category] = (countByCategory[prompt.category] ?? 0) + 1;
      }
    }

    final minCount = countByCategory.values.reduce((a, b) => a < b ? a : b);
    final leastUsedCategories = countByCategory.entries
        .where((entry) => entry.value == minCount)
        .map((entry) => entry.key)
        .toSet();

    final candidates = prompts.where((prompt) => leastUsedCategories.contains(prompt.category)).toList();
    final recentPromptId = _checkins.isNotEmpty ? _checkins.last.promptId : null;
    final filtered = candidates.where((prompt) => prompt.id != recentPromptId).toList();
    final pool = filtered.isNotEmpty ? filtered : candidates;

    if (pool.isEmpty) {
      return prompts.first;
    }

    final selectedIndex = _checkins.length % pool.length;
    return pool[selectedIndex];
  }

  void _handlePromptSelected(PromptOption prompt) {
    setState(() {
      _selectedPrompt = prompt;
      _step = FlowStep.compose;
    });
  }

  void _handleBackToQuestion() {
    setState(() {
      _step = FlowStep.question;
    });
  }

  void _handleSubmit({
    required String text,
    required List<String> emotions,
  }) {
    final prompt = _selectedPrompt;
    if (prompt == null) return;

    final keywords = ReflectionEngine.deriveKeywords(text, emotions);
    final reflectionLine = ReflectionEngine.buildReflectionLine(keywords, emotions);

    setState(() {
      _checkins.add(
        CheckIn(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          promptId: prompt.id,
          promptLabel: prompt.label,
          text: text.trim(),
          emotions: emotions,
          keywords: keywords,
          reflectionLine: reflectionLine,
          createdAt: DateTime.now(),
        ),
      );
      _step = FlowStep.reflection;
    });
  }

  void _handleNextCheckin() {
    setState(() {
      _selectedPrompt = null;
      _step = FlowStep.question;
    });
  }

  void _handleResetData() {
    setState(() {
      _selectedPrompt = null;
      _checkins.clear();
      _step = FlowStep.question;
    });
  }

  void _handleSeedData() {
    setState(() {
      _checkins
        ..clear()
        ..addAll(buildSampleCheckins());
      _step = FlowStep.reflection;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case FlowStep.question:
        return QuestionSelectScreen(
          prompts: prompts,
          recommendedPrompt: _buildBalancedRecommendation(),
          onSelected: _handlePromptSelected,
        );
      case FlowStep.compose:
        final prompt = _selectedPrompt;
        if (prompt == null) {
          return QuestionSelectScreen(
            prompts: prompts,
            recommendedPrompt: _buildBalancedRecommendation(),
            onSelected: _handlePromptSelected,
          );
        }
        return CheckInComposeScreen(
          prompt: prompt,
          emotions: ReflectionEngine.emotionOptions,
          onBack: _handleBackToQuestion,
          onSubmit: _handleSubmit,
        );
      case FlowStep.reflection:
        return ReflectionFeedScreen(
          checkins: _checkins,
          onNextCheckin: _handleNextCheckin,
          onResetData: _handleResetData,
          onSeedData: _handleSeedData,
        );
    }
  }
}
