@immutable
class ServerCartItemDto {
  final String skuId;
  final int quantity;

  const ServerCartItemDto({required this.skuId, required this.quantity});

  factory ServerCartItemDto.fromJson(Map<String, dynamic> json) {
    return ServerCartItemDto(
      skuId: json['sku_id'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
