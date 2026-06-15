import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Использовано для демонстрации, в проде лучше web_socket_channel

import '../../domain/i_websocket_client.dart';
import '../../domain/ws_connection_state.dart';
import '../dtos/outgoing_frame_dto.dart';
import '../utils/retry_policy.dart';

class WebSocketClientImpl implements IWebSocketClient {
  final RetryPolicy _retryPolicy = RetryPolicy();

  // Реальный сокет (библиотека/sdk под капотом)
  WebSocket? _socket;
  StreamSubscription? _socketSubscription;

  WsConnectionState _state = WsConnectionState.disconnected;
  int _currentSeqId = 0;
  int _reconnectAttempts = 0;

  final Map<int, OutgoingFrame> _unacknowledgedBuffer = {};

  // Контроллеры стримов
  final _statusController = StreamController<WsConnectionState>.broadcast();
  final _messageController = StreamController<String>.broadcast();

  @override
  Stream<WsConnectionState> get statusStream => _statusController.stream;

  @override
  Stream<String> get messageStream => _messageController.stream;

  // Метод переключения стейта теперь приватный внутри реализации
  void _changeState(WsConnectionState newState) {
    _state = newState;
    _statusController.add(newState);
  }

  @override
  Future<void> connect() async {
    if (_state == WsConnectionState.connected ||
        _state == WsConnectionState.connecting)
      return;

    _changeState(WsConnectionState.connecting);
    await _establishConnection();
  }

  /// Внутренний метод создания подключения и подписки на сырой поток байт/строк
  Future<void> _establishConnection() async {
    try {
      // Инициализируем реальное соединение
      _socket = await WebSocket.connect('wss://api.example.com/ws');

      _reconnectAttempts = 0;
      _changeState(WsConnectionState.connected);

      // Важно: Слушаем сырой поток из сокета
      _socketSubscription = _socket?.listen(
        (rawMessage) => _handleIncomingRawMessage(rawMessage as String),
        onDone: _handleConnectionLoss,
        onError: (_) => _handleConnectionLoss(),
      );

      _flushBuffer();
    } catch (e) {
      _handleConnectionLoss();
    }
  }

  /// СЕРДЦЕ ИНКАПСУЛЯЦИИ: Парсинг сырых пакетов от сервера
  void _handleIncomingRawMessage(String rawMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(rawMessage);

      // 1. Проверяем, не является ли пакет системным ACK-подтверждением
      if (json['type'] == 'ack' && json['seq_id'] != null) {
        final confirmedSeqId = json['seq_id'] as int;
        _onAckReceived(confirmedSeqId);
        return; // Тормозим ивент, бизнесу этот технический пакет не нужен
      }

      // 2. Если это не системный ACK, значит это бизнес-данные (для BLoC)
      // Прокидываем чистую строку дальше в публичный стрим
      _messageController.add(rawMessage);
    } catch (e) {
      // Логирование ошибки парсинга, битый JSON от сервера
    }
  }

  /// Метод обработки подтверждения пакета (теперь скрыт от внешнего мира)
  void _onAckReceived(int confirmedSeqId) {
    _unacknowledgedBuffer.remove(confirmedSeqId);
  }

  @override
  void send(String jsonPayload) {
    _currentSeqId++;
    final frame = OutgoingFrame(
      seqId: _currentSeqId,
      payload: jsonPayload,
      createdAt: DateTime.now(),
    );

    _unacknowledgedBuffer[frame.seqId] = frame;

    if (_state == WsConnectionState.connected) {
      _sendToSocket(frame);
    }
  }

  void _sendToSocket(OutgoingFrame frame) {
    // Формируем обертку с метаданными для бэкенда, чтобы бэкенд знал seq_id
    final transportJson = {
      'seq_id': frame.seqId,
      'payload': frame
          .payload, // Внутри payload лежит бизнес-json, сгенерированный в BLoC
    };
    _socket?.add(jsonEncode(transportJson));
  }

  /// Логика обработки падения линка (вызывается из onDone/onError или при таймауте)
  void _handleConnectionLoss() async {
    if (_state == WsConnectionState.reconnecting ||
        _state == WsConnectionState.disconnected)
      return;

    _cleanUpSocket();
    _changeState(WsConnectionState.reconnecting);

    while (_reconnectAttempts < _retryPolicy.maxAttempts) {
      final delay = _retryPolicy.calculateDelay(_reconnectAttempts);
      await Future.delayed(delay);

      // Если пока мы спали по таймеру, пришел вызов disconnect() сверху
      if (_state == WsConnectionState.disconnected) return;

      try {
        await _establishConnection();
        return; // Успешно переподключились, выходим из цикла
      } catch (e) {
        _reconnectAttempts++;
      }
    }

    _changeState(WsConnectionState.failed);
  }

  @override
  Future<void> disconnect() async {
    _changeState(WsConnectionState.disconnected);
    await _cleanUpSocket();
    _unacknowledgedBuffer
        .clear(); // Сбрасываем буфер, так как это намеренный выход
  }

  Future<void> _cleanUpSocket() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _socket?.close();
    _socket = null;
  }

  void _flushBuffer() {
    for (final frame in _unacknowledgedBuffer.values) {
      _sendToSocket(frame);
    }
  }
}
