// Направление: Backend -> Client

/// Перечисление возможных первичных статусов платежа от бэкенда
enum InitialPaymentStatus {
  /// Платеж успешно завершен сразу (редко, например, если оплата в 1 клик без 3DS)
  success,

  /// Требуется прохождение аутентификации 3D-Secure (наш основной кейс)
  threeDSecureRequired,

  /// Ошибка на стороне эквайринга/банка при попытке зарегистрировать платеж
  rejected,
}

class InitiatePaymentResponseDto {
  final InitialPaymentStatus status;

  /// Ссылка на платежную страницу банка (ACS URL).
  /// Присутствует СТРОГО если статус == [InitialPaymentStatus.threeDsRequired]
  final String? acsUrl;

  /// Уникальный идентификатор транзакции в нашей системе (нужен для последующего опроса статуса)
  final String paymentTransactionId;

  const InitiatePaymentResponseDto({
    required this.status,
    required this.paymentTransactionId,
    this.acsUrl,
  });

  factory InitiatePaymentResponseDto.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentResponseDto(
      status: _parseStatus(json['status'] as String),
      paymentTransactionId: json['payment_transaction_id'] as String,
      acsUrl: json['acs_url'] as String?,
    );
  }

  static InitialPaymentStatus _parseStatus(String status) {
    switch (status) {
      case 'SUCCESS':
        return InitialPaymentStatus.success;
      case 'THREE_D_SECURE_REQUIRED':
        return InitialPaymentStatus.threeDSecureRequired;
      case 'REJECTED':
        return InitialPaymentStatus.rejected;
      default:
        throw ArgumentError('Unknown InitialPaymentStatus: $status');
    }
  }
}
