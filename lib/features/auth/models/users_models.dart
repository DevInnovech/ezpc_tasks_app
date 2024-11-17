// Clase UserModel
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String lastName;
  final String phoneNumber;
  final String username;
  final String role;
  final String uniqueCode;
  final String country;
  final String state;
  final String address;
  final String profileImageUrl; // Nuevo campo

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    required this.username,
    required this.role,
    required this.uniqueCode,
    this.country = '',
    this.state = '',
    this.address = '',
    this.profileImageUrl = '', // Valor predeterminado
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'username': username,
      'role': role,
      'uniqueCode': uniqueCode,
      'country': country,
      'state': state,
      'address': address,
      'profileImageUrl': profileImageUrl, // Agregado a la conversión
      'createdAt': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      uniqueCode: map['uniqueCode'] ?? '',
      country: map['country'] ?? '',
      state: map['state'] ?? '',
      address: map['address'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}
