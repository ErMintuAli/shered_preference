class Users{
  late String name;
  late String email;
  late String phone;

  Users({required this.name, required this.email, required this.phone});

  Map<String, String> toUser() {
    return{
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  static Users fromUsers(Map<String, dynamic> user) {
    return Users(
      name: user['name']!,
      email: user['email']!,
      phone: user['phone']!,

    );
  }
}