class PasswordItem {
  final String id;
  final String appName;
  final String username;
  final String password;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  PasswordItem({
    required this.id,
    required this.appName,
    required this.username,
    required this.password,
    DateTime? createdAt,
    this.isDeleted = false,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PasswordItem copyWith({
    String? id,
    String? appName,
    String? username,
    String? password,
    DateTime? createdAt,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory PasswordItem.fromJson(Map<String, dynamic> json) {
    return PasswordItem(
      id: json['id'] as String? ?? '',
      appName: json['appName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordItem &&
        other.id == id &&
        other.appName == appName &&
        other.username == username &&
        other.password == password &&
        other.isDeleted == isDeleted &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, appName, username, password, isDeleted, deletedAt);

  @override
  String toString() {
    // Security precaution: never expose the raw password in logs or string representations
    return 'PasswordItem(id: $id, appName: $appName, username: $username, password: [PROTECTED], createdAt: $createdAt, isDeleted: $isDeleted)';
  }
}
