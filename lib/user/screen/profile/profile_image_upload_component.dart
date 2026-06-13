import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';
import 'package:mma_flutter/user/repository/user_repository.dart';

class ProfileImageUploadComponent extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileImageUploadComponent({required this.user, super.key});

  @override
  ConsumerState<ProfileImageUploadComponent> createState() =>
      _ProfileImageUploadComponentState();
}

class _ProfileImageUploadComponentState
    extends ConsumerState<ProfileImageUploadComponent> {
  String? imageToShow;

  @override
  void initState() {
    imageToShow = widget.user.profileImgUrl;
    super.initState();
  }

  final picker = ImagePicker();
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        imageToShow == null
            ? _defaultProfileImgIcon
            : GestureDetector(
              onTap: () => _showEditImageDialog(context),
              child: CachedNetworkImage(
                imageUrl: imageToShow!,
                imageBuilder: (context, imageProvider) {
                  return CircleAvatar(
                    backgroundImage: imageProvider,
                    radius: 50.sp,
                  );
                },
                placeholder: (context, url) => _defaultProfileImgIcon,
                errorWidget: (context, url, error) {
                  log('$error');
                  return _defaultProfileImgIcon;
                },
              ),
            ),
        if (imageToShow == null)
          Positioned(
            bottom: 0.h,
            right: -2.w,
            child: IconButton(
              onPressed: uploadPickedImage,
              icon: Icon(
                Icons.photo_camera_outlined,
                color: context.colors.surface,
                size: 22.sp,
              ),
            ),
          ),
      ],
    );
  }

  void _showEditImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: Text('프로필 사진'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  uploadPickedImage();
                },
                child: Text('사진 변경'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteProfileImage();
                },
                child: Text('사진 삭제'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('취소'),
              ),
            ],
          );
        }

        return AlertDialog(
          backgroundColor: DARK_GREY_COLOR,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          actionsPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          title: Text(
            '프로필 사진',
            style: TextStyle(color: WHITE_COLOR, fontWeight: FontWeight.w700, fontSize: 16.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: WHITE_COLOR, size: 22.sp),
                title: Text('사진 변경', style: TextStyle(color: WHITE_COLOR, fontSize: 14.sp)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  uploadPickedImage();
                },
              ),
              Divider(color: GREY_COLOR, height: 1, indent: 16.w, endIndent: 16.w),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.redAccent, size: 22.sp),
                title: Text('사진 삭제', style: TextStyle(color: Colors.redAccent, fontSize: 14.sp)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _deleteProfileImage();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('취소', style: TextStyle(color: LIGHT_GREY_COLOR, fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfileImage() async {
    try {
      await ref.read(userRepositoryProvider).deleteProfileImage();
      if (mounted) {
        setState(() {
          imageToShow = null;
        });
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예상치 못한 오류 발생')),
        );
      }
    }
  }

  void uploadPickedImage() async {
    selectedImage = await pickAndCropImage();
    if (selectedImage != null) {
      final file = File(selectedImage!.path);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final res = await ref
          .read(userProvider.notifier)
          .uploadProfileImg(imgData: formData, user: widget.user);
      if (res.isEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 중 오류가 발생했습니다. 다시 시도해주세요'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      setState(() {
        imageToShow = res;
      });
    }
  }

  Future<File?> pickAndCropImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return null;
    }
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '프로필 사진 자르기',
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: '프로필 사진 자르기'),
      ],
    );
    if (croppedFile == null) {
      return null;
    }
    return File(croppedFile.path);
  }

  Widget get _defaultProfileImgIcon => Container(
    height: 100.h,
    width: 100.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colors.onSurface,
      border: Border.all(color: GREY_COLOR, width: 4.w),
    ),
    child: Icon(Icons.person_outlined, color: GREY_COLOR, size: 55.sp),
  );
}
