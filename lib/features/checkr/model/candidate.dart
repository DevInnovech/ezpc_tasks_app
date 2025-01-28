class Candidate {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String workLocation;
  final String zipcode;

  Candidate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.workLocation,
    required this.zipcode,
  });

  // Convierte los datos a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'work_location': workLocation,
      'zipcode': zipcode,
    };
  }

  // Crea un objeto Candidate desde una respuesta JSON
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      workLocation: json['work_location'],
      zipcode: json['zipcode'],
    );
  }
}
