import 'ws_connection_state.dart';

abstract class IWebSocketClient {
  /// Стрим для отслеживания состояния сети (нужен для UI баннеров и блокировки кнопок)
  Stream<WsConnectionState> get statusStream;

  /// Стрим входящих текстовых сообщений от сервера (JSON-строки)
  Stream<String> get messageStream;

  /// Инициализация соединения (вызывается при старте приложения или авторизации)
  Future<void> connect();

  /// Безопасная отправка бизнес-сообщений.
  /// Внешний код не знает про seqId, буферы и retry-политики.
  void send(String payload);

  /// Намеренное закрытие соединения (например, при логауте пользователя)
  Future<void> disconnect();
}
