import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int    id,
    required String username,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name')  required String lastName,
    required String role,
    @Default('') String telephone,
    String? photo,
    @JsonKey(name: 'is_verified')  @Default(false) bool isVerified,
    @JsonKey(name: 'is_superuser') @Default(false) bool isSuperuser,
    @JsonKey(name: 'is_staff')     @Default(false) bool isStaff,
    @JsonKey(name: 'profil_producteur_statut') String? profilProducteurStatut,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
