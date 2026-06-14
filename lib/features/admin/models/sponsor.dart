class Sponsor {
  const Sponsor({
    required this.id,
    required this.name,
    required this.country,
    this.email,
    this.message,
  });

  final String id;
  final String name;
  final String country;
  final String? email;
  final String? message;

  Sponsor copyWith({
    String? id,
    String? name,
    String? country,
    String? email,
    String? message,
  }) {
    return Sponsor(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      email: email ?? this.email,
      message: message ?? this.message,
    );
  }
}
