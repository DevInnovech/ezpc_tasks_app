class Candidate {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<Map<String, dynamic>> workLocations;
  final String zipcode;

  Candidate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.workLocations,
    required this.zipcode,
  });

  // Converts the candidate data to JSON for the API
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'work_locations': workLocations,
      'zipcode': zipcode,
    };
  }

  // Creates a Candidate object from a JSON response
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      workLocations: List<Map<String, dynamic>>.from(json['work_locations']),
      zipcode: json['zipcode'],
    );
  }
}
