import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/main.dart';

class RetryButton extends StatefulWidget {
  final VoidCallback onRetry;

  const RetryButton({required this.onRetry, super.key});

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.box,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8.r),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () {
                setState(() => _isLoading = true);
                widget.onRetry();
              },
        child: _isLoading
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.onSurface,
                ),
              )
            : const Text('다시시도'),
      ),
    );
  }
}
