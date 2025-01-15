import 'package:flutter/material.dart';

import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:bebikame/view/dialog/confirmation_dialog.dart';
import 'package:bebikame/view/dialog/error_dialog.dart';
import 'package:bebikame/view/dialog/message_dialog.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';

Future<int?> showSettingsDialog(
  BuildContext context,
  int? savedShootingTime,
  VoidCallback onSuccessRestore,
) async {
  double currentValue = savedShootingTime?.toDouble() ?? 15;

  final result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('設定', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('録画時間（秒）'),
                Slider(
                  value: currentValue,
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: currentValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      currentValue = value;
                    });
                  },
                ),
                Text('${currentValue.round()}秒',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(currentValue.round()),
                      child: const Text(
                        '保存',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: _buildInAppPurchaseRestoreButton(
                  context,
                  onSuccessRestore,
                ),
              ),
            ],
          );
        },
      );
    },
  );
  return result;
}

Widget _buildInAppPurchaseRestoreButton(
    BuildContext context, VoidCallback updateGridItems) {
  final inAppPurchaseService = getIt<InAppPurchaseService>();

  return TextButton(
    onPressed: () async {
      try {
        final result = await showConfirmationDialog(
          context: context,
          title: '購入済み商品の復元',
          content: '購入済み商品を復元しますか？',
        );
        if (!result) return;

        final beforeRestorePurchasedProductIdsCount =
            inAppPurchaseService.purchasedProductIds.length;

        if (context.mounted) {
          final isSuccessRestore = await LoadingOverlay.of(context).during(
            () => inAppPurchaseService.getPastPurchases(),
          );
          if (!isSuccessRestore) {
            throw Exception('購入済み商品の復元に失敗しました。\n再度お試しください。');
          }

          if (context.mounted) {
            if (inAppPurchaseService.purchasedProductIds.length >
                beforeRestorePurchasedProductIdsCount) {
              showMessageDialog(
                context: context,
                title: '復元成功',
                content: '購入済み商品を復元しました。',
              );
              updateGridItems();
            } else {
              showMessageDialog(
                context: context,
                title: '復元処理完了',
                content: '復元可能な購入済み商品はありませんでした。',
              );
            }
          }
        }
      } catch (e) {
        if (context.mounted) showErrorDialog(context, e.toString());
      }
    },
    child: const Text('購入済み商品の復元', style: TextStyle(fontSize: 14)),
  );
}
