/// Направление: Client -> Backend (GET /api/v1/payments/status?transaction_id=...)
class PaymentStatusRequestDto {
  final String paymentTransactionId;

  const PaymentStatusRequestDto({required this.paymentTransactionId});
}
