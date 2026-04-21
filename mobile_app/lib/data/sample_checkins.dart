import '../models/checkin.dart';
import '../utils/reflection_engine.dart';

List<CheckIn> buildSampleCheckins() {
  final raw = [
    (
      promptId: 'thought',
      promptLabel: '요즘 자주 붙잡히는 생각은 무엇인가요?',
      text: '회사에서 지금 하는 일이 길게 봤을 때 맞는 방향인지 자꾸 확인하게 돼요.',
      emotions: ['불안', '압박감'],
    ),
    (
      promptId: 'identity',
      promptLabel: '지금의 나를 한 문장으로 표현하면 어떤가요?',
      text: '앞으로 가고는 있는데 확신보다는 점검에 더 가까운 사람 같아요.',
      emotions: ['혼란', '불안'],
    ),
    (
      promptId: 'emotion',
      promptLabel: '최근 반복해서 느끼는 감정은 무엇인가요?',
      text: '새로운 선택지를 생각하면 기대도 되지만 당장 결정해야 할 것 같아 압박감이 커져요.',
      emotions: ['기대', '압박감'],
    ),
    (
      promptId: 'thought',
      promptLabel: '요즘 자주 붙잡히는 생각은 무엇인가요?',
      text: '요즘은 성과보다 앞으로 어떤 방향으로 움직일지가 더 크게 보여요.',
      emotions: ['불안', '기대'],
    ),
    (
      promptId: 'emotion',
      promptLabel: '최근 반복해서 느끼는 감정은 무엇인가요?',
      text: '쉬어야 하는데 멈추면 뒤처질까 봐 압박이 계속 남아 있어요.',
      emotions: ['압박감', '무기력'],
    ),
  ];

  return List<CheckIn>.generate(raw.length, (index) {
    final item = raw[index];
    final keywords = ReflectionEngine.deriveKeywords(item.text, item.emotions);
    return CheckIn(
      id: 'sample-${index + 1}',
      promptId: item.promptId,
      promptLabel: item.promptLabel,
      text: item.text,
      emotions: item.emotions,
      keywords: keywords,
      reflectionLine: ReflectionEngine.buildReflectionLine(keywords, item.emotions),
      createdAt: DateTime.now().subtract(Duration(days: raw.length - index)),
    );
  });
}
