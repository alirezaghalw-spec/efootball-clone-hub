class AccountModel {
  final String id;
  final String name;
  final String konamiId;
  final bool isActive;
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.konamiId,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'konamiId': konamiId,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        konamiId: json['konamiId'] as String,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  AccountModel copyWith({String? name, String? konamiId, bool? isActive}) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      konamiId: konamiId ?? this.konamiId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
