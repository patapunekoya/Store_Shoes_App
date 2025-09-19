class User {
  final String id;
  final String email;
  final String role;
  final String? fullName;
  User({required this.id, required this.email, required this.role, this.fullName});

  factory User.fromJson(Map<String, dynamic> j) =>
      User(id: j['id'], email: j['email'], role: j['role'], fullName: j['fullName']);
}
