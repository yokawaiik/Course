@immutable
class LocalCartItemDto {
  final String skuId;
  final int quantity;

  const LocalCartItemDto({required this.skuId, required this.quantity});

  Map<String, dynamic> toJson() => {'sku_id': skuId, 'quantity': quantity};
}
