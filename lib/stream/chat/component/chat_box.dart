import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/report/component/report_dialog.dart';
import 'package:mma_flutter/stream/chat/model/chat_response_model.dart';
import 'package:mma_flutter/stream/model/stream_message_request_model.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatBox extends ConsumerWidget {
  final WebSocketChannel socket;
  final UserModel user;
  final ChatResponseModel chatResponse;

  const ChatBox({
    required this.socket,
    required this.user,
    required this.chatResponse,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isMine = user.id == chatResponse.userId;
    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 0 : 18.w,
        right: isMine ? 8.w : 0,
      ),
      child: Align(
        alignment:
            user.id == chatResponse.userId
                ? Alignment.centerRight
                : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // info (user meta info(profile image, nickname, belt, ...)
            if (!isMine)
              Padding(
                padding: EdgeInsets.only(bottom: 4.w),
                child: SizedBox(
                  child: Row(
                    children: [
                      if (chatResponse.profileImgUrl != null)
                        GestureDetector(
                          onTap:
                              () => _showProfileImage(
                                context,
                                chatResponse.profileImgUrl!,
                              ),
                          child: Hero(
                            tag: 'profile_${chatResponse.messageId}',
                            child: CachedNetworkImage(
                              imageUrl: chatResponse.profileImgUrl!,
                              imageBuilder: (context, imageProvider) {
                                return CircleAvatar(
                                  backgroundImage: imageProvider,
                                  radius: 14.sp,
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container();
                              },
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          chatResponse.nickname,
                          style: context.text.bodyMedium,
                        ),
                      ),
                      beltByPoint(
                        point: chatResponse.earnedBetSucceedPoint,
                        width: 19.w,
                        height: 19.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: _renderBlockOrReport(
                          context,
                          chatResponse: chatResponse,
                          ref: ref,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // message
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5,
              ),
              decoration: BoxDecoration(
                color:
                    user.id == chatResponse.userId ? WHITE_COLOR : BLACK_COLOR,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                child: Text(
                  chatResponse.message,
                  style: TextStyle(
                    color:
                        user.id == chatResponse.userId
                            ? BLACK_COLOR
                            : MID_GREY_COLOR,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
            SizedBox(
              child: Text(
                CustomDateUtils.formatDateTime(chatResponse.createdAt),
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: MID_GREY_COLOR
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Hero(
                  tag: 'profile_${chatResponse.messageId}',
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 200.w,
                    height: 200.w,
                    fit: BoxFit.cover,
                    imageBuilder:
                        (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 100.w,
                        ),
                    errorWidget:
                        (context, url, error) => CircleAvatar(
                          radius: 100.w,
                          backgroundColor: DARK_GREY_COLOR,
                          child: Icon(
                            Icons.person,
                            size: 80.w,
                            color: GREY_COLOR,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _renderBlockOrReport(
    BuildContext context, {
    required ChatResponseModel chatResponse,
    required WidgetRef ref,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _renderTextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                void onBlock() {
                  socket.sink.add(
                    json.encode(
                      StreamMessageRequestModel(
                        requestMessageType: RequestMessageType.block,
                        userIdToBlock: chatResponse.userId,
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('해당 사용자에 대한 차단이 완료되었습니다.')),
                  );
                }

                if (Platform.isIOS) {
                  return CupertinoAlertDialog(
                    title: Text('이 사용자를 차단하시겠습니까?'),
                    content: Text('차단하시면, 채팅 세션 동안 이 사용자의 메시지를 볼 수 없게 됩니다.'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('취소'),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: onBlock,
                        child: Text('차단'),
                      ),
                    ],
                  );
                }

                return AlertDialog(
                  backgroundColor: DARK_GREY_COLOR,
                  title: Text(
                    '이 사용자를 차단하시겠습니까?',
                    style: TextStyle(
                      color: WHITE_COLOR,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  content: Text(
                    '차단하시면, 채팅 세션 동안 이 사용자의 메시지를 볼 수 없게 됩니다.',
                    style: TextStyle(fontSize: 13.sp, color: LIGHT_GREY_COLOR),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '취소',
                        style: TextStyle(color: LIGHT_GREY_COLOR),
                      ),
                    ),
                    TextButton(
                      onPressed: onBlock,
                      child: Text(
                        '차단',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          label: '차단',
        ),
        Text(' | ', style: TextStyle(color: GREY_COLOR, fontSize: 14.sp)),
        _renderTextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => ReportUserDialog(
                    reportedUserId: chatResponse.userId,
                    messageId: chatResponse.messageId,
                    messageSnapshot: chatResponse.message,
                  ),
            );
          },
          label: '신고',
        ),
      ],
    );
  }

  TextButton _renderTextButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // 좌우 여백 제거
        minimumSize: Size(0, 0), // 높이 최소화
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: GREY_COLOR, fontSize: 14.sp)),
    );
  }
}
