import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

abstract class PaginationBase {}

class PaginationError extends PaginationBase {
  final String message;

  PaginationError({required this.message});
}

class PaginationLoading extends PaginationBase {}

@JsonSerializable(genericArgumentFactories: true)
class Pagination<T> extends PaginationBase {
  @JsonKey(
    fromJson: PaginationMeta.fromRootJson,
    toJson: PaginationMeta.toRootJson,
  )
  final PaginationMeta meta;

  final List<T> content;

  Pagination({required this.meta, required this.content});

  Pagination copyWith({PaginationMeta? meta, List<T>? content}) {
    return Pagination<T>(
      meta: meta ?? this.meta,
      content: content ?? this.content,
    );
  }

  /**
   * fromJson이 generic 타입을 반환하는 경우, generic type 반환하는 함수를 인자로 넣어야
   * 올바르게 genetic type 고려한 code generation 수행함
   */
  factory Pagination.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return Pagination(
      content: (json['content'] as List<dynamic>).map(fromJsonT).toList(),
      meta: PaginationMeta.fromRootJson(json),
    );
  }
}

class PaginationMeta {
  // 페이지 번호
  final int number;
  final bool empty;

  PaginationMeta({
    required this.number,
    required this.empty,
  });

  factory PaginationMeta.fromRootJson(Map<String, dynamic> json) {
    return PaginationMeta(
      number: json['number'] as int,
      empty: json['empty'] as bool,
    );
  }

  static Map<String, dynamic> toRootJson(PaginationMeta meta) => {
    'number': meta.number,
    'empty': meta.empty,
  };
}

// 이미 데이터가 있는 상태에서 추가 데이터를 요청하는 상태
// (엄밀히 말하면 로딩이지만, 데이터가 있는 상태에서 로딩하는 것이므로 둘이 상태를 다르게 정의함)
class PaginationFetchingMore<T> extends Pagination<T> {
  PaginationFetchingMore({required super.meta, required super.content});
}
