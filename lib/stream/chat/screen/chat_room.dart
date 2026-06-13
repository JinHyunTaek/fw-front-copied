import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/report/model/report_request_model.dart';
import 'package:mma_flutter/stream/chat/component/chat_box.dart';
import 'package:mma_flutter/stream/chat/model/chat_request_model.dart';
import 'package:mma_flutter/stream/chat/model/chat_response_model.dart';
import 'package:mma_flutter/stream/model/stream_message_request_model.dart';
import 'package:mma_flutter/stream/provider/stream_component_providers.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoom extends ConsumerStatefulWidget {
  final UserModel user;
  final WebSocketChannel socket;

  const ChatRoom({required this.user, required this.socket, super.key});

  @override
  ConsumerState<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends ConsumerState<ChatRoom>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final chatList = <ChatResponseModel>[];
  final scrollController = ScrollController();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listenManual<ChatResponseModel?>(chatResponseProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        setState(() {
          chatList.add(next);
        });
      }
    });
    _initRecentMessages();
  }

  void _initRecentMessages() {
    final recent = ref.read(recentChatMessagesProvider);
    void applyRecentMessages(List<ChatResponseModel> list) {
      setState(() {
        chatList.addAll(list);
      });
    }
    if (recent != null) {
      applyRecentMessages(recent);
      return;
    }
    ref.listenManual<List<ChatResponseModel>?>(recentChatMessagesProvider, (
      prev,
      next,
    ) {
      if (next != null) {
        applyRecentMessages(next);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(recentChatMessagesProvider) == null) {
      return Container(
        color: context.colors.surface,
        child: CustomCircularProgressIndicator(),
      );
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final connectionCount = ref.watch(connectionCountProvider);

    super.build(context);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    });
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: context.colors.box,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.remove_red_eye_outlined,
                                size: 17.r,
                                color: context.colors.onSurface,
                              ),
                            ),
                            WidgetSpan(child: SizedBox(width: 4.0)),
                            TextSpan(
                              text: NumberFormat('#,###').format(connectionCount),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: context.colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        // reverse: true,
                        itemBuilder: (_, index) {
                          return ChatBox(
                            socket: widget.socket,
                            user: widget.user,
                            chatResponse: chatList[index],
                          );
                        },
                        separatorBuilder: (_, index) {
                          return const SizedBox(height: 12);
                        },
                        itemCount: chatList.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              color: context.colors.box,
              child: SizedBox(
                height: 45.h,
                child: TextField(
                  style: context.text.bodyMedium,
                  cursorColor: context.colors.onSurface,
                  decoration: InputDecoration(
                    border: linearGradientInputBorder,
                    fillColor: context.colors.surface,
                    filled: true,
                    suffixIcon: IconButton(
                      padding: EdgeInsets.only(right: 4.w),
                      onPressed: () {
                        _sendMessage(widget.socket);
                      },
                      icon: Icon(
                        FontAwesomeIcons.paperPlane,
                        color: context.colors.onSurface,
                        size: 20.r,
                      ),
                    ),
                  ),
                  controller: textController,
                  // 엔터키로 전송
                  onSubmitted: (value) => _sendMessage(widget.socket),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _sendMessage(socket) {
    if(widget.user.reportedReason != null){
      textController.clear();
      final reason = widget.user.reportedReason!;
      final releaseAt = widget.user.restrictEndAt!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${reason.label} 사유로 채팅 이용이 7일간 제한되었습니다.\n'
            '해제 예정 시각: ${CustomDateUtils.formatDateTime(releaseAt)}')),
      );
      return;
    }
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      socket.sink.add(
        json.encode(
          StreamMessageRequestModel(
            requestMessageType: RequestMessageType.talk,
            chatMessageRequest: ChatRequestModel(message: text),
          ),
        ),
      );
    }
    textController.clear();
  }
}
