class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        role.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

