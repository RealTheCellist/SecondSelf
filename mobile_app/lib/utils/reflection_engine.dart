import '../models/checkin.dart';

class ReflectionSummary {
  final String stage;
  final List<String> topTopics;
  final List<String> topEmotions;
  final String summaryLine;

  const ReflectionSummary({
    required this.stage,
    required this.topTopics,
    required this.topEmotions,
    required this.summaryLine,
  });
}

class ReflectionEngine {
  static const emotionOptions = [
    '불안',
    '압박감',
    '기대',
    '자신감',
    '혼란',
    '안정감',
    '의욕',
    '무기력',
  ];

  static const _keywordMap = [
    ('일', ['일', '회사', '업무', '직장', '프로젝트', '성과']),
    ('방향성', ['방향', '진로', '앞으로', '커리어', '선택', '전환']),
    ('관계', ['관계', '사람', '대화', '팀', '가족', '친구']),
    ('불확실성', ['불확실', '모르', '애매', '걱정', '확신']),
    ('정리', ['정리', '정돈', '정리하다', '정돈감']),
    ('휴식', ['쉬', '휴식', '피곤', '지침', '지쳤']),
    ('회복', ['회복', '버티', '괜찮아지', '진정']),
    ('압박', ['압박', '부담', '마감', '쫓기']),
  ];

  static List<String> deriveKeywords(String text, List<String> emotions) {
    final lowered = text.toLowerCase();
    final found = <String>[];

    for (final (keyword, triggers) in _keywordMap) {
      if (triggers.any(lowered.contains)) {
        found.add(keyword);
      }
    }

    if (emotions.contains('불안') && !found.contains('불확실성')) {
      found.add('불확실성');
    }

    if ((emotions.contains('무기력') || emotions.contains('안정감')) && !found.contains('회복')) {
      found.add('회복');
    }

    if (emotions.contains('압박감') && !found.contains('압박')) {
      found.add('압박');
    }

    if (found.isEmpty) {
      found.add('정리');
    }

    return found.toSet().take(2).toList();
  }

  static String buildReflectionLine(List<String> keywords, List<String> emotions) {
    if (keywords.contains('방향성') && emotions.contains('불안')) {
      return '요즘 당신은 결과보다 방향을 더 오래 붙잡고 있습니다.';
    }
    if (keywords.contains('관계') && emotions.contains('혼란')) {
      return '최근의 당신은 관계 속 거리감과 해석 사이에서 오래 머무르고 있습니다.';
    }
    if (keywords.contains('정리')) {
      return '지금의 당신은 확신보다 정돈에 더 에너지를 쓰고 있습니다.';
    }
    if (emotions.contains('압박감')) {
      return '최근의 당신은 해야 할 것들의 무게를 오래 안고 움직이고 있습니다.';
    }
    if (keywords.contains('휴식') && emotions.contains('무기력')) {
      return '지금의 당신은 더 달리기보다 먼저 회복의 여지를 찾고 있습니다.';
    }
    if (keywords.contains('일') && emotions.contains('기대')) {
      return '최근의 당신은 부담 속에서도 다음 기회를 함께 바라보고 있습니다.';
    }
    if (keywords.contains('관계') && emotions.contains('불안')) {
      return '요즘 당신은 관계의 거리와 마음의 안전함을 함께 살피고 있습니다.';
    }
    if (keywords.contains('회복') || keywords.contains('휴식')) {
      return '최근의 당신은 버티는 것보다 회복하는 방식에 더 마음이 가고 있습니다.';
    }
    if (keywords.contains('방향성')) {
      return '최근의 당신은 멈춤보다 다음 방향을 가늠하는 일에 더 오래 머무르고 있습니다.';
    }
    if (emotions.contains('기대')) {
      return '요즘 당신은 불안보다 가능성 쪽으로 마음을 조금 더 기울이고 있습니다.';
    }

    return '지금의 당신은 정리되지 않은 감정과 생각을 한곳에 모아보려 하고 있습니다.';
  }

  static ReflectionSummary summarize(List<CheckIn> checkins) {
    if (checkins.isEmpty) {
      return const ReflectionSummary(
        stage: 'empty',
        topTopics: [],
        topEmotions: [],
        summaryLine: '오늘의 한 줄부터 시작해볼까요? 짧은 입력 하나면 충분합니다.',
      );
    }

    final recent = checkins.length > 5 ? checkins.sublist(checkins.length - 5) : checkins;
    final topicCount = <String, int>{};
    final emotionCount = <String, int>{};

    for (final checkin in recent) {
      for (final keyword in checkin.keywords) {
        topicCount[keyword] = (topicCount[keyword] ?? 0) + 1;
      }
      for (final emotion in checkin.emotions) {
        emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
      }
    }

    final topTopics = topicCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotions = emotionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topicValues = topTopics.take(3).map((entry) => entry.key).toList();
    final emotionValues = topEmotions.take(2).map((entry) => entry.key).toList();

    return ReflectionSummary(
      stage: recent.length < 3
          ? 'early'
          : recent.length < 5
              ? 'preview'
              : 'full',
      topTopics: topicValues,
      topEmotions: emotionValues,
      summaryLine: _createSummaryLine(topicValues, emotionValues),
    );
  }

  static String _createSummaryLine(List<String> topTopics, List<String> topEmotions) {
    final firstTopic = topTopics.isNotEmpty ? topTopics.first : '정리';
    final firstEmotion = topEmotions.isNotEmpty ? topEmotions.first : '혼란';

    final hasDirection = topTopics.contains('방향성');
    final hasRelationship = topTopics.contains('관계');
    final hasWork = topTopics.contains('일');
    final hasRecovery = topTopics.contains('회복') || topTopics.contains('휴식');
    final hasPressure = topEmotions.contains('압박감');
    final hasAnxiety = topEmotions.contains('불안');

    if (hasDirection && hasAnxiety) {
      return '요즘 당신은 성과보다 앞으로의 방향을 더 자주 고민하고 있습니다.';
    }
    if (hasRelationship && hasAnxiety) {
      return '최근의 당신은 사람 사이의 거리와 마음의 안전함을 함께 살피고 있습니다.';
    }
    if (hasRelationship) {
      return '최근의 당신은 관계 속 거리와 연결감에 더 민감하게 반응하고 있습니다.';
    }
    if (hasWork && hasPressure) {
      return '당신은 해야 할 일의 무게 속에서도 흐름을 잃지 않으려 애쓰고 있습니다.';
    }
    if (hasRecovery) {
      return '최근의 당신은 더 밀어붙이기보다 회복할 수 있는 리듬을 찾고 있습니다.';
    }
    if (firstTopic == '방향성') {
      return '요즘의 당신은 지금 잘하고 있는지보다 어디로 가고 있는지를 더 자주 확인하고 있습니다.';
    }
    if (firstEmotion == '기대' && topTopics.length > 1) {
      return '최근의 당신은 ${topTopics[1]}에 대한 부담보다 가능성을 조금 더 오래 바라보고 있습니다.';
    }

    return '최근의 당신은 흩어진 생각과 감정을 한데 모아 자기 흐름을 읽어내려 하고 있습니다.';
  }
}
