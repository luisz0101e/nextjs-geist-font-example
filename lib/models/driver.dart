class Driver {
  final String id;
  final String name;
  final String licensePlate;
  final String licenseNumber;
  final bool isVerified;
  final String phone;
  final double rating;

  Driver({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.licenseNumber,
    required this.isVerified,
    required this.phone,
    required this.rating,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      licensePlate: json['licensePlate'],
      licenseNumber: json['licenseNumber'],
      isVerified: json['isVerified'],
      phone: json['phone'],
      rating: json['rating'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'licensePlate': licensePlate,
      'licenseNumber': licenseNumber,
      'isVerified': isVerified,
      'phone': phone,
      'rating': rating,
    };
  }
}
