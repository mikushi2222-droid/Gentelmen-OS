import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // TODO: загружать из KnowledgeRepository
    final content = _sampleContent(articleId);

    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Закладка',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'В избранное',
            onPressed: () {},
          ),
        ],
      ),
      body: Markdown(
        data: content.body,
        padding: const EdgeInsets.all(Spacing.screenPadding),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium,
          h1: Theme.of(context).textTheme.headlineMedium,
          h2: Theme.of(context).textTheme.headlineSmall,
          h3: Theme.of(context).textTheme.titleLarge,
          blockquoteDecoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            border: Border(
              left: BorderSide(color: cs.primary, width: 3),
            ),
          ),
        ),
      ),
    );
  }

  _ArticleContent _sampleContent(String id) => switch (id) {
        'fit-blazer' => const _ArticleContent(
            title: 'Как должен сидеть пиджак',
            body: '''
# Как должен сидеть пиджак

Правильная посадка пиджака — основа делового и классического образа.

## Плечи

Шов между плечом и рукавом должен заканчиваться **там, где заканчивается ваше плечо** — не раньше и не позже. Свисающий шов — признак чужого пиджака.

## Длина рукава

Из-под рукава должно быть видно **1–1.5 см манжеты рубашки**. Это показывает, что под пиджаком есть рубашка с правильной посадкой.

## Прилегание в груди

Пиджак должен застёгиваться **без заломов «X»** на пуговице. Если ткань расходится веером — пиджак мал. Если болтается — велик.

## Длина

Классическая длина — **до середины ладони** при опущенных руках. Короче — спортивнее. Длиннее — серьёзнее.

## Для крупной фигуры

> Выбирайте пиджаки с **умеренно широкими лацканами** и **структурированными плечами**. Это визуально создаёт ширину плеч и уравновешивает объём в талии.

Избегайте слишком узких лацканов — они акцентируют объём корпуса.
''',
          ),
        'large-fit-trousers' => const _ArticleContent(
            title: 'Посадка брюк для крупной фигуры',
            body: '''
# Посадка брюк для крупной фигуры

## Главное правило

Средняя или **высокая посадка** — ваш лучший выбор. Она визуально удлиняет ноги и не давит на живот.

## Что избегать

- Низкая посадка: «провисает», визуально укорачивает фигуру.
- Slim fit: обтягивающие брюки подчёркивают объём бёдер и живота.

## Что выбирать

- **Regular Fit** или **Straight Fit** с небольшим запасом в бедре.
- Хлопок плотного плетения (Chino Twill) или шерстяная смесь.
- Тёмные нейтральные цвета: navy, серый, антрацит.

## Бренды

Meyer Roma, Club of Comfort Garvey — специально созданы для комфортного ношения при большом объёме бедра и талии.

## Ателье

После покупки отдайте брюки в ателье: попросите усилить шаговый шов и поставить ластовицу. Это увеличит срок жизни брюк в 2–3 раза.
''',
          ),
        _ => _ArticleContent(
            title: 'Статья $id',
            body: '# $id\n\nСодержимое статьи загружается...',
          ),
      };
}

class _ArticleContent {
  const _ArticleContent({required this.title, required this.body});

  final String title;
  final String body;
}
