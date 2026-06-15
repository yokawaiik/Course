import 'dart:convert';

import '../../../shared/api/websocket/domain/i_websocket_client.dart';
import '../../../shared/api/websocket/domain/ws_connection_state.dart';

class CartBloc {
  final IWebSocketClient _wsClient;

  CartBloc(this._wsClient) {
    // Подписываемся на статус сети, чтобы реагировать в UI
    _wsClient.statusStream.listen(_handleNetworkStatus);
  }

  void onQuantityChanged(String skuId, int newQuantity) {
    final command = {
      "action": "cart.item.update",
      "sku_id": skuId,
      "quantity": newQuantity,
    };

    // Просто отправляем. О гарантированной доставке позаботится shared/api
    _wsClient.send(jsonEncode(command));
  }

  void _handleNetworkStatus(WsConnectionState state) {
    if (state == WsConnectionState.failed) {
      // Бизнес-логика: генерируем стейт CartState.error(message: "Проблемы с соединением. Обновляем локально.")
    }
    // ...
  }
}
