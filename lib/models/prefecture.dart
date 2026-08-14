/// 学習コンテンツカードの種別
enum CardType { text, image, stats }

/// コンテンツカード（1枚のスライド）
class ContentCard {
  final CardType type;
  final String? content;       // type=text のとき
  final String? imageUrl;      // type=image のとき
  final String? caption;       // type=image のとき
  final String? statsLabel;    // type=stats のとき（例: "面積"）
  final String? statsValue;    // type=stats のとき（例: "83,000km²"）

  const ContentCard({
    required this.type,
    this.content,
    this.imageUrl,
    this.caption,
    this.statsLabel,
    this.statsValue,
  });

  factory ContentCard.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'text';
    final CardType cardType = switch (typeStr) {
      'image' => CardType.image,
      'stats' => CardType.stats,
      _ => CardType.text,
    };
    // stats フィールドはフラット形式（statsLabel/statsValue）と
    // ネスト形式（data.label/data.value）の両方をサポート
    final statsData = json['data'] as Map<String, dynamic>?;
    return ContentCard(
      type: cardType,
      content: json['content'] as String?,
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String?,
      statsLabel: json['statsLabel'] as String? ?? statsData?['label'] as String?,
      statsValue: json['statsValue'] as String? ?? statsData?['value'] as String?,
    );
  }
}

/// 学習ステップ（各県3ステップ構成）
class StudyStep {
  final int stepNo;        // 1, 2, 3
  final String title;      // "基本情報", "産業", "文化・観光・先人"
  final List<ContentCard> cards;

  const StudyStep({
    required this.stepNo,
    required this.title,
    required this.cards,
  });

  factory StudyStep.fromJson(Map<String, dynamic> json) {
    return StudyStep(
      stepNo: json['stepNo'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      cards: (json['cards'] as List<dynamic>? ?? [])
          .map((c) => ContentCard.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 都道府県モデル（Firestore ドキュメントに対応）
class Prefecture {
  final String id;          // "hokkaido"
  final String name;        // "北海道"
  final String region;      // "hokkaido_tohoku"
  final String imageUrl;
  final List<StudyStep> steps;
  final String badgeId;     // "hokkaido_master"

  const Prefecture({
    required this.id,
    required this.name,
    required this.region,
    required this.imageUrl,
    required this.steps,
    required this.badgeId,
  });

  factory Prefecture.fromJson(Map<String, dynamic> json) {
    return Prefecture(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((s) => StudyStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      badgeId: json['badgeId'] as String? ?? '${json['id']}_master',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'region': region,
        'imageUrl': imageUrl,
        'badgeId': badgeId,
      };
}
