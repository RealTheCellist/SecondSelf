enum PromptCategory {
  selfAwareness,
  emotion,
  relationship,
  growth,
}

extension PromptCategoryX on PromptCategory {
  String get label {
    switch (this) {
      case PromptCategory.selfAwareness:
        return '자기 인식';
      case PromptCategory.emotion:
        return '감정';
      case PromptCategory.relationship:
        return '관계와 경계';
      case PromptCategory.growth:
        return '변화와 성장';
    }
  }
}

class PromptOption {
  final String id;
  final String label;
  final PromptCategory category;

  const PromptOption({
    required this.id,
    required this.label,
    required this.category,
  });
}
