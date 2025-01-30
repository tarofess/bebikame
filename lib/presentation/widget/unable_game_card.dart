import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/presentation/dialog/message_dialog.dart';

class UnableGameCard extends ConsumerWidget {
  final String imagePath;

  const UnableGameCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => showMessageDialog(
          context: context,
          title: 'アプリ内課金アイテム取得エラー',
          content: 'ネットワークに接続されていないためアプリ内課金の情報が取得できません。\n'
              'アプリ内課金アイテムを取得するためにネットワークに接続してからアプリを再起動してください。',
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(
                [
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ],
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
