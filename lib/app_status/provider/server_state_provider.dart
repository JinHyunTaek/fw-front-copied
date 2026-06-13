import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServerState { normal, maintenance, timeout }

final serverStateProvider = StateProvider<ServerState>((ref) => ServerState.normal);
