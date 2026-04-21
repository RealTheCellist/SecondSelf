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
    PromptOption(id: 'thought', label: '요즘 자주 붙잡히는 생각은 무엇인가요?'),
    PromptOption(id: 'emotion', label: '최근 반복해서 느끼는 감정은 무엇인가요?'),
    PromptOption(id: 'identity', label: '지금의 나를 한 문장으로 표현하면 어떤가요?'),
  ];

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
          onSelected: _handlePromptSelected,
        );
      case FlowStep.compose:
        final prompt = _selectedPrompt;
        if (prompt == null) {
          return QuestionSelectScreen(
            prompts: prompts,
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
