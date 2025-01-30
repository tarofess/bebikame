import 'dart:math';
import 'package:flutter/material.dart';

import 'package:bebikame/domain/result.dart';

Future<Result> showParentalGateDialog({required BuildContext context}) async {
  final random = Random();
  final num1 = random.nextInt(10) + 1;
  final num2 = random.nextInt(10) + 1;
  int answer = num1 * num2;
  String inputAnswer = '';

  final result = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: const Text('あなたが保護者であることを確認します'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$num1 × $num2 はいくつですか？'),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      inputAnswer = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      const Failure(
                        '保護者であることを確認できた後にコンテンツを購入できます。',
                      ),
                    );
                  },
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (inputAnswer == answer.toString()) {
                      Navigator.of(context).pop(const Success(null));
                    } else {
                      Navigator.of(context).pop(
                        const Failure(
                          '回答が間違っているためコンテンツを購入できませんでした。',
                        ),
                      );
                    }
                  },
                  child: const Text('回答'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  return result ?? false;
}
