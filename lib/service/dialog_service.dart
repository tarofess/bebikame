import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:flutter/material.dart';

class DialogService {
  Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String okButtonText,
    String cancelButtonText,
  ) async {
    final result = await _showConfirmationDialogBase(
      context: context,
      title: title,
      content: content,
      okButtonText: okButtonText,
      cancelButtonText: cancelButtonText,
      handleOKButtonPress: (dialogContext) =>
          Navigator.of(dialogContext).pop(true),
      handleCancelButtonPress: (dialogContext) =>
          Navigator.of(dialogContext).pop(false),
    );
    return result ?? false;
  }

  Future<void> showMessageDialog(
      BuildContext context, String title, String content) async {
    await _showSingleButtonDialogBase(
      context: context,
      title: title,
      content: content,
      buttonText: 'はい',
      handleButtonPress: (dialogContext) => Navigator.of(dialogContext).pop(),
    );
  }

  Future<void> showErrorDialog(BuildContext context, String content) async {
    await _showSingleButtonDialogBase(
      context: context,
      title: 'エラー',
      content: content,
      buttonText: 'はい',
      handleButtonPress: (dialogContext) => Navigator.of(dialogContext).pop(),
    );
  }

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

  Future<T> _showConfirmationDialogBase<T>({
    required BuildContext context,
    required String title,
    required String content,
    required String okButtonText,
    required String cancelButtonText,
    required Function(BuildContext dialogContext) handleOKButtonPress,
    required Function(BuildContext dialogContext) handleCancelButtonPress,
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          content: Text(content),
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
                    onPressed: () => handleCancelButtonPress(context),
                    child: Text(
                      cancelButtonText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                    onPressed: () async => await handleOKButtonPress(context),
                    child: Text(
                      okButtonText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSingleButtonDialogBase({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    required Function(BuildContext dialogContext) handleButtonPress,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(content),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => handleButtonPress(dialogContext),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInAppPurchaseRestoreButton(
      BuildContext context, VoidCallback updateGridItems) {
    final dialogService = getIt<DialogService>();
    final inAppPurchaseService = getIt<InAppPurchaseService>();

    return TextButton(
      onPressed: () async {
        try {
          final result = await dialogService.showConfirmationDialog(
            context,
            '購入済み商品の復元',
            '購入済み商品を復元しますか？',
            'はい',
            'いいえ',
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
                dialogService.showMessageDialog(
                    context, '復元成功', '購入済み商品を復元しました。');
                updateGridItems();
              } else {
                dialogService.showMessageDialog(
                    context, '復元処理完了', '復元可能な購入済み商品はありませんでした。');
              }
            }
          }
        } catch (e) {
          if (context.mounted) {
            dialogService.showErrorDialog(context, e.toString());
          }
        }
      },
      child: const Text('購入済み商品の復元', style: TextStyle(fontSize: 14)),
    );
  }
}
