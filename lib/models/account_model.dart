import 'dart:convert';

class AccountModel {
  final String id;
  final String name;
  final String konamiId;
  final bool isActive;
  final DateTime createdAt;

  AccountModel({
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
        id: json['id'],
        name: json['name'],
        konamiId: json['konamiId'],
        isActive: json['isActive'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  AccountModel copyWith({
    String? name,
    String? konamiId,
    bool? isActive,
  }) {
    return AccountModel(
      id: this.id,
      name: name ?? this.name,
      konamiId: konamiId ?? this.konamiId,
      isActive: isActive ?? this.isActive,
      createdAt: this.createdAt,
    );
  }
}
