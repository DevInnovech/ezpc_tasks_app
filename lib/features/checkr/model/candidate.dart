class Candidate {
  String firstName;
  String lastName;
  String email;
  String phone;
  String workLocation;
  String customId;

  Candidate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.workLocation,
    required this.customId,
  });

  Map<String, String> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'work_location': workLocation,
      'custom_id': customId,
    };
  }
}
