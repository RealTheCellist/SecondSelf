class CheckIn {
  final String id;
  final String promptId;
  final String promptLabel;
  final String text;
  final List<String> emotions;
  final List<String> keywords;
  final String reflectionLine;
  final DateTime createdAt;

  const CheckIn({
    required this.id,
    required this.promptId,
    required this.promptLabel,
    required this.text,
    required this.emotions,
    required this.keywords,
    required this.reflectionLine,
    required this.createdAt,
  });
}
