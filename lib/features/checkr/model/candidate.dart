class Candidate {
  late final String firstName;
  late final String lastName;
  late final String email;
  late final String phone;
  late final String dob; // Fecha de nacimiento en formato YYYY-MM-DD
  late final String ssn; // Número de seguro social (mock)

  Candidate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.ssn,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'dob': dob,
      'ssn': ssn,
    };
  }
}
