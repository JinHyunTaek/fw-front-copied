import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/stream/model/stream_message_response_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final socketProvider = Provider.autoDispose<WebSocketChannel>((ref) {
  final wsUrl = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
  final channel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws/stream'));
  ref.onDispose(() => channel.sink.close(),);
  return channel;
});

final socketResponseProvider = StreamProvider.autoDispose<StreamMessageResponseModel>((
  ref,
) {
  ref.onDispose(() => log('dispose socketResponseProvider'),);
  return ref.read(socketProvider).stream.map((event) {
    try {
      log('incoming: $event');
      final decoded = json.decode(event);
      final parsed = StreamMessageResponseModel.fromJson(decoded);
      return parsed;
    } catch (e, st) {
      log('parse error: $e\n$st');
      rethrow;
    }
  });
});
