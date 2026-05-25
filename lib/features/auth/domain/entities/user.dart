import 'package:equatable/equatable.dart';

/// Pure domain entity — no JSON logic here.
class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.token,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, username, email];
}
