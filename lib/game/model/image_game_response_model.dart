import 'package:json_annotation/json_annotation.dart';

part 'image_game_response_model.g.dart';

@JsonSerializable()
class ImageGameResponseModel {
  final String name;
  final String answer;
  final List<String> wrongSelections;

  ImageGameResponseModel({
    required this.name,
    required this.answer,
    required this.wrongSelections,
  });

  factory ImageGameResponseModel.fromJson(Map<String, dynamic> json)
  => _$ImageGameResponseModelFromJson(json);
}
