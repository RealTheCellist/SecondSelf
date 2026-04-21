import 'package:flutter/material.dart';

import '../models/checkin.dart';
import '../utils/reflection_engine.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_badge.dart';
import '../widgets/secondary_button.dart';

class ReflectionFeedScreen extends StatelessWidget {
  final List<CheckIn> checkins;
  final VoidCallback onNextCheckin;
  final VoidCallback onResetData;
  final VoidCallback onSeedData;

  const ReflectionFeedScreen({
    super.key,
    required this.checkins,
    required this.onNextCheckin,
    required this.onResetData,
    required this.onSeedData,
  });

  @override
  Widget build(BuildContext context) {
    final latest = checkins.isNotEmpty ? checkins.last : null;
    final summary = ReflectionEngine.summarize(checkins);
    final textTheme = Theme.of(context).textTheme;

    final bottomBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: SecondaryButton(label: '기록 초기화', onPressed: onResetData)),
            const SizedBox(width: 10),
            Expanded(child: SecondaryButton(label: '샘플 채우기', onPressed: onSeedData)),
          ],
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: latest == null ? '첫 체크인 시작하기' : '다음 체크인 남기기',
          onPressed: onNextCheckin,
        ),
      ],
    );

    return AppScaffold(
      bottomBar: bottomBar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgressBadge(label: '3 / 3'),
          const SizedBox(height: 20),
          Text('지금의 나를 비추면', style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            latest?.reflectionLine ?? summary.summaryLine,
            style: textTheme.titleLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (latest?.keywords ?? ['오늘', '시작'])
                .map(
                  (keyword) => Chip(
                    label: Text(keyword),
                    backgroundColor: const Color(0xFFE7D4C4),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '완전히 맞지 않아도 괜찮습니다. 지금의 나를 가볍게 비춰보는 중이니까요.',
            style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF74675B)),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text('최근의 나는 이렇게 반복되고 있어요', style: textTheme.titleLarge),
              const Spacer(),
              Chip(label: Text(_stageLabel(summary.stage))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _stageDescription(summary.stage),
            style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B)),
          ),
          const SizedBox(height: 16),
          if (summary.stage == 'empty' || summary.stage == 'early')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('아직은 오늘의 한 줄이 더 정확합니다', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '체크인이 몇 번 더 쌓이면, 반복되는 감정과 주제를 함께 보여드릴게요.',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _PatternCard(title: '자주 나온 주제', body: summary.topTopics.join(', ')),
            _PatternCard(title: '반복 감정', body: summary.topEmotions.join(', ')),
            _PatternCard(title: '최근의 나', body: summary.summaryLine),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  label: '누적 체크인',
                  value: '${checkins.length}회',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightCard(
                  label: '가장 많이 고른 감정',
                  value: summary.topEmotions.isNotEmpty ? summary.topEmotions.first : '아직 없음',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('최근 체크인', style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: checkins.reversed
                .map(
                  (checkin) => Chip(
                    label: Text('${checkin.createdAt.month}.${checkin.createdAt.day} · ${checkin.emotions.join('/')}'),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _stageLabel(String stage) {
    switch (stage) {
      case 'empty':
        return '준비';
      case 'early':
        return '초기';
      case 'preview':
        return '미리보기';
      case 'full':
        return '완성';
      default:
        return stage;
    }
  }

  String _stageDescription(String stage) {
    switch (stage) {
      case 'empty':
        return '체크인이 쌓일수록 반복되는 흐름이 더 선명해집니다';
      case 'early':
        return '최근 5번의 체크인이 쌓이면 더 선명한 흐름을 보여드릴게요';
      case 'preview':
        return '3회 이상 쌓인 체크인을 기준으로 먼저 보이는 흐름입니다';
      case 'full':
        return '최근 5번의 체크인에서 자주 나온 흐름입니다';
      default:
        return '';
    }
  }
}

class _PatternCard extends StatelessWidget {
  final String title;
  final String body;

  const _PatternCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF74675B))),
              const SizedBox(height: 8),
              Text(body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;

  const _InsightCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF74675B))),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
