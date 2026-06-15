import 'package:meta/meta.dart';

import 'local_cart_item_dto.dart';

@immutable
class SyncCartRequestDto {
  final int lastKnownRevision;
  final List<LocalCartItemDto> items;

  const SyncCartRequestDto({
    required this.lastKnownRevision,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'last_known_revision': lastKnownRevision,
    'items': items.map((e) => e.toJson()).toList(),
  };
}
