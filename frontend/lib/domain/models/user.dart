class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String? currentCity;
  final String? currentCountry;
  final String rol;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    this.currentCity,
    this.currentCountry,
    required this.rol,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      surname: (json['surname'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      currentCity: json['currentCity'] as String?,
      currentCountry: json['currentCountry'] as String?,
      rol: (json['rol'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'currentCity': currentCity,
      'currentCountry': currentCountry,
      'rol': rol,
    };
  }
}
