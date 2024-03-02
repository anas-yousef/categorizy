import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  User copy({
    String? id,
    String? firstName,
    String? lastName,
  }) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName];
}
