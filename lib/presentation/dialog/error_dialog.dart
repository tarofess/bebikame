import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, dynamic error) async {
  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Center(
          child: Text('エラー発生'),
        ),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Center(child: Text('はい')),
          ),
        ],
      );
    },
  );
}
