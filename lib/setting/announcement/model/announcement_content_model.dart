import 'package:json_annotation/json_annotation.dart';

part 'announcement_content_model.g.dart';

@JsonSerializable()
class AnnouncementContentModel {

  final String content;

  AnnouncementContentModel({required this.content});

  factory AnnouncementContentModel.fromJson(Map<String, dynamic> json)
  => _$AnnouncementContentModelFromJson(json);

}
