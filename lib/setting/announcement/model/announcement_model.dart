import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';

part 'announcement_model.g.dart';

@JsonSerializable()
class AnnouncementModel implements ModelWithId {
  @override
  final int id;
  final String title;
  final bool pinned;
  final DateTime createdDate;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.pinned,
    required this.createdDate,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);
}
