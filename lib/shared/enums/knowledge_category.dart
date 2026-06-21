enum KnowledgeCategory {
  style,
  etiquette,
  grooming,
  fabrics,
  shoes,
  suits,
  casual,
  health,
  discipline,
  reading;

  String get label => switch (this) {
        KnowledgeCategory.style => 'Стиль',
        KnowledgeCategory.etiquette => 'Этикет',
        KnowledgeCategory.grooming => 'Груминг',
        KnowledgeCategory.fabrics => 'Ткани',
        KnowledgeCategory.shoes => 'Обувь',
        KnowledgeCategory.suits => 'Костюмы',
        KnowledgeCategory.casual => 'Кэжуал',
        KnowledgeCategory.health => 'Здоровье',
        KnowledgeCategory.discipline => 'Дисциплина',
        KnowledgeCategory.reading => 'Чтение',
      };
}
