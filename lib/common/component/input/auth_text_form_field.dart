import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';

class AuthTextFormField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final bool autofocus;
  final String? Function(String?)? validator;
  final double? borderSideWidth;
  final ValueChanged<String>? onChanged;
  final double? borderRadiusSize;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final Color? borderSideColor;
  final BoxConstraints? suffixConstraints;
  final GlobalKey<FormFieldState>? formFieldKey;
  final double? width;

  const AuthTextFormField({
    required this.onChanged,
    this.obscureText = false,
    this.autofocus = false,
    this.borderSideWidth,
    this.borderRadiusSize,
    this.controller,
    this.hintText,
    this.validator,
    this.suffixIcon,
    this.textStyle,
    this.borderSideColor,
    this.suffixConstraints,
    this.formFieldKey,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius:
          borderRadiusSize == null
              ? BorderRadius.zero
              : BorderRadius.circular(borderRadiusSize!),
      borderSide: BorderSide(
        width: borderSideWidth ?? 1.0,
        color: borderSideColor ?? MID_GREY_COLOR,
      ),
    );
    return SizedBox(
      width: width ?? 302.w,
      child: TextFormField(
        key: formFieldKey,
        controller: controller,
        style: textStyle ?? context.text.bodySmall,
        validator: validator,
        cursorColor: textStyle != null ? textStyle!.color : context.colors.onSurface,
        // 비밀번호 입력할 때
        obscureText: obscureText,
        autofocus: autofocus,
        onChanged: onChanged,
        decoration: InputDecoration(
          errorStyle: TextStyle(
            color: Color(0xffe3233c),
            fontSize: 12.sp
          ),
          isDense: true,
          contentPadding: EdgeInsets.only(left: 16.w, bottom: 10.h, top: 10.h),
          hintText: hintText,
          hintStyle: TextStyle(
            color: GREY_COLOR,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          fillColor: context.colors.surface,
          filled: true,
          border: baseBorder,
          // 텍스트 필드 선택 시 border 적용
          enabledBorder: baseBorder,
          focusedBorder: baseBorder.copyWith(
            borderSide: baseBorder.borderSide.copyWith(
              color: borderSideColor ?? context.colors.onSurface,
            ),
          ),
          errorBorder: baseBorder.copyWith(
            borderSide: baseBorder.borderSide.copyWith(
              color: Color(0xffe3233c),
            ),
          ),
          focusedErrorBorder: baseBorder.copyWith(
            borderSide: baseBorder.borderSide.copyWith(
              color: Color(0xffe3233c),
            ),
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: suffixConstraints,
        ),
      ),
    );
  }
}
