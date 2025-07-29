class UserModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String photo;
  final String password; 

  UserModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.photo,
    required this.password,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      photo: map['photo'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'photo': photo,
      'password': password,
    };
  }
}
