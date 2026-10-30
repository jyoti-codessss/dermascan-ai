class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? gender;
  final String? skinType;
  final int? age;
  final String? primaryConcern;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.gender,
    this.skinType,
    this.age,
    this.primaryConcern,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? gender,
    String? skinType,
    int? age,
    String? primaryConcern,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      skinType: skinType ?? this.skinType,
      age: age ?? this.age,
      primaryConcern: primaryConcern ?? this.primaryConcern,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'skinType': skinType,
        'age': age,
        'primaryConcern': primaryConcern,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? json['name'] as String? ?? 'User',
        photoUrl: json['photoUrl'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        gender: json['gender'] as String?,
        skinType: json['skinType'] as String?,
        age: json['age'] as int?,
        primaryConcern: json['primaryConcern'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
