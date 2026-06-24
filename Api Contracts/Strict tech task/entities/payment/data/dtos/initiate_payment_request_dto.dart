/// Направление: Client -> Backend (POST /api/v1/payments/initiate)
class InitiatePaymentRequestDto {
  final String orderId;

  const InitiatePaymentRequestDto({required this.orderId});

  Map<String, dynamic> toJson() => {'order_id': orderId};
}
