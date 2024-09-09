import 'package:flutter/material.dart';

class DialogService {
  Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String okButtonText,
    String cancelButtonText,
  ) async {
    final result = await showConfirmationDialogBase(
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
    await showSingleButtonDialogBase(
      context: context,
      title: title,
      content: content,
      buttonText: 'はい',
      handleButtonPress: (dialogContext) => Navigator.of(dialogContext).pop(),
    );
  }

  Future<void> showErrorDialog(BuildContext context, String content) async {
    await showSingleButtonDialogBase(
      context: context,
      title: 'エラー',
      content: content,
      buttonText: 'はい',
      handleButtonPress: (dialogContext) => Navigator.of(dialogContext).pop(),
    );
  }

  Future<int?> showSettingsDialog(
      BuildContext context, int? savedShootingTime) async {
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
              ],
            );
          },
        );
      },
    );
    return result;
  }

  Future<T> showConfirmationDialogBase<T>({
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

  Future<void> showSingleButtonDialogBase({
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
}
