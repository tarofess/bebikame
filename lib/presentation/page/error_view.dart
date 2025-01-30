import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback retry;

  const ErrorView({super.key, this.error, required this.retry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('アプリの初期化に失敗しました。\n再度お試しください。'),
            SizedBox(height: 16.r),
            Text(
              '$error',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.r),
            ElevatedButton(
              onPressed: retry,
              child: const Text('リトライ'),
            ),
          ],
        ),
      ),
    );
  }
}
