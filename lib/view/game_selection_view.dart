import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/model/game.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/view/game_preview_view.dart';
import 'package:bebikame/view/widget/game_card.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameSelectionView extends ConsumerWidget {
  final _dialogService = getIt<DialogService>();
  final _inAppPurchaseService = getIt<InAppPurchaseService>();

  GameSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ゲームを選んでね！'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              try {
                await _handleSettingButtonPress(context);
              } catch (e) {
                if (context.mounted) {
                  _dialogService.showErrorDialog(context, e.toString());
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: game.length,
              itemBuilder: (context, index) {
                return GameCard(
                  imagePath: game[index].image,
                  isLocked: game[index].isLocked,
                  onTap: () async {
                    try {
                      await _handleGridTilePress(context, ref, game[index]);
                    } catch (e) {
                      if (context.mounted) {
                        _dialogService.showErrorDialog(context, e.toString());
                      }
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGridTilePress(
      BuildContext context, WidgetRef ref, Game game) async {
    if (game.isLocked) {
      final result = await _dialogService.showConfirmationDialog(
        context,
        game.name,
        'このゲームはロックされています。\n購入してロックを解除しますか？',
        '購入する',
        'キャンセル',
      );
      if (!result) return;

      if (context.mounted) {
        final isSuccessPurchase = await LoadingOverlay.of(context).during(
          () => _handleInAppPurchase(game, ref),
        );
        if (!isSuccessPurchase) {
          throw Exception('購入処理が完了できませんでした。\n再度お試しください。');
        }
      }
    }

    if (context.mounted) await goToGamePreviewView(context, ref, game);
  }

  Future<bool> _handleInAppPurchase(Game game, WidgetRef ref) async {
    try {
      final purchaseStarted = await _inAppPurchaseService
          .buyProduct(_inAppPurchaseService.getProductByName(game)!);

      if (!purchaseStarted) {
        return false;
      }

      final purchaseResult =
          await _inAppPurchaseService.purchaseResultStream.first;

      if (purchaseResult && game.name == '花火ゲーム') {
        ref.read(gameProvider.notifier).unlockedFireWorksGame();
      } else if (purchaseResult && game.name == '音楽ゲーム') {
        ref.read(gameProvider.notifier).unlockedMusicGame();
      }

      return purchaseResult;
    } catch (e) {
      throw Exception('購入処理中に予期せぬエラーが発生しました。\n再度お試しください。');
    }
  }

  Future<void> _handleSettingButtonPress(BuildContext context) async {
    final sharedPrefService = getIt<SharedPreferencesService>();
    final savedShootingTime = await sharedPrefService.getShootingTime();
    if (context.mounted) {
      final result =
          await _dialogService.showSettingsDialog(context, savedShootingTime);
      if (result != null) {
        await sharedPrefService.saveShootingTime(result);
      }
    }
  }

  Future<void> goToGamePreviewView(
      BuildContext context, WidgetRef ref, Game game) async {
    final navigationService = getIt<NavigationService>();
    final audioService = getIt<AudioService>();
    await audioService.play('button_tap');
    ref.read(gameProvider.notifier).updateGameSelected(game.name);
    if (context.mounted) {
      navigationService.push(context, GamePreviewView());
    }
  }
}
