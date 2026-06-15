import 'package:meta/meta.dart';

import 'server_cart_item_dto.dart';

@immutable
class SyncCartResponseDto {
  final int actualRevision;
  final List<ServerCartItemDto> items;

  const SyncCartResponseDto({
    required this.actualRevision,
    required this.items,
  });

  factory SyncCartResponseDto.fromJson(Map<String, dynamic> json) {
    return SyncCartResponseDto(
      actualRevision: json['actual_revision'] as int,
      items: (json['merged_items'] as List<dynamic>)
          .map((e) => ServerCartItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
