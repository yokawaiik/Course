/// Обертка для любого бизнес-сообщения
class OutgoingFrame {
  final int seqId;
  final String payload; // Тут лежит наш JSON (например, изменение корзины)
  final DateTime createdAt;

  OutgoingFrame({
    required this.seqId,
    required this.payload,
    required this.createdAt,
  });
}
