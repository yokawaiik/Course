import '../../domain/entities/final_payment_status.dart';

/// Направление: Backend -> Client
class PaymentStatusResponseDto {
  final FinalPaymentStatus status;

  /// Локализуемое сообщение от банка об ошибке (если платеж не прошел),
  /// которое можно безопасно показать пользователю.
  final String? displayErrorMessage;

  const PaymentStatusResponseDto({
    required this.status,
    this.displayErrorMessage,
  });

  factory PaymentStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponseDto(
      status: _parseFinalStatus(json['status'] as String),
      displayErrorMessage: json['display_error_message'] as String?,
    );
  }

  static FinalPaymentStatus _parseFinalStatus(String status) {
    switch (status) {
      case 'SUCCESS':
        return FinalPaymentStatus.success;
      case 'PENDING':
        return FinalPaymentStatus.pending;
      case 'INSUFFICIENT_FUNDS':
        return FinalPaymentStatus.insufficientFunds;
      case 'THREE_DS_FAILED':
        return FinalPaymentStatus.threeDSecureFailed;
      case 'CARD_EXPIRED':
        return FinalPaymentStatus.cardExpired;
      case 'CARD_RESTRICTED':
        return FinalPaymentStatus.cardRestricted;
      case 'DECLINED':
        return FinalPaymentStatus.declined;
      default:
        return FinalPaymentStatus.declined; // Fallback для безопасности
    }
  }
}
