import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final bool isHigherAccess;
  final int reputationScore;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.isHigherAccess = false,
    this.reputationScore = 0,
    required this.createdAt,
  });

  // Generate anonymous user
  factory User.anonymous() {
    const uuid = Uuid();
    return User(
      id: uuid.v4(),
      name: 'Anonymous',
      isHigherAccess: false,
      reputationScore: 0,
      createdAt: DateTime.now(),
    );
  }

  // Create higher-access user
  factory User.higherAccess(String userId, String name) {
    return User(
      id: userId,
      name: name,
      isHigherAccess: true,
      reputationScore: 100,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isHigherAccess': isHigherAccess,
      'reputationScore': reputationScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      isHigherAccess: json['isHigherAccess'] ?? false,
      reputationScore: json['reputationScore'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isHigherAccess': isHigherAccess ? 1 : 0,
      'reputationScore': reputationScore,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      isHigherAccess: map['isHigherAccess'] == 1,
      reputationScore: map['reputationScore'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  User copyWith({
    String? id,
    String? name,
    bool? isHigherAccess,
    int? reputationScore,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      isHigherAccess: isHigherAccess ?? this.isHigherAccess,
      reputationScore: reputationScore ?? this.reputationScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

