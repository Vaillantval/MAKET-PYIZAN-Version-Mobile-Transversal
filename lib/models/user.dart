import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int    id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    @Default('') String telephone,
    String? photo,
    @Default(false) bool isVerified,
    @Default(false) bool isSuperuser,
    @Default(false) bool isStaff,
    String? profilProducteurStatut,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
