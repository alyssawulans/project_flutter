import 'package:json_annotation/json_annotation.dart';
import 'package:ppkd_b6/day_37/models/firestore_date_time_converter.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModelFirebase {
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;

  UserModelFirebase({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserModelFirebase.fromJson(Map<String, dynamic> json) =>
      _$UserModelFirebaseFromJson(json);

  factory UserModelFirebase.fromMap(Map<String, dynamic> map) =>
      UserModelFirebase.fromJson(map);

  Map<String, dynamic> toJson() => _$UserModelFirebaseToJson(this);

  Map<String, dynamic> toMap() => toJson();
}
