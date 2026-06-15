import 'dart:math';

class RetryPolicy {
  final int maxAttempts = 5;
  final Duration baseDelay = const Duration(seconds: 2);
  final Duration maxDelay = const Duration(seconds: 32);
  final Random _random = Random();

  RetryPolicy();

  Duration calculateDelay(int attempt) {
    if (attempt >= maxAttempts) return maxDelay;

    // Экспоненциальная задержка: base * 2^attempt
    final double ticks = baseDelay.inMilliseconds * pow(2, attempt).toDouble();
    final int calculatedMs = ticks.toInt();

    // Добавляем Джиттер (±15% от текущего времени ожидания)
    final int jitterRange = (calculatedMs * 0.15).toInt();
    final int jitter = _random.nextInt(jitterRange * 2) - jitterRange;

    final int finalMs = (calculatedMs + jitter).clamp(
      baseDelay.inMilliseconds,
      maxDelay.inMilliseconds,
    );

    return Duration(milliseconds: finalMs);
  }
}
