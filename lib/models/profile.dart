class UserProfile {
  final String id;
  final String name;
  final String emoji;
  final String createdAt; // ISO8601 string

  const UserProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'createdAt': createdAt,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    createdAt: json['createdAt'] as String,
  );
}

// よく使う絵文字リスト
const kProfileEmojis = ['🦊','🐱','🐶','🐼','🐨','🐯','🦁','🐸','🐧','🦉','🐝','🌸','⭐','🌈','🎈','🎮','📚','🌟','🔥','💎'];
