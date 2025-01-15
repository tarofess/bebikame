import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/get_it.dart';
import 'package:bebikame/model/game.dart';
import 'package:bebikame/provider/is_enable_in_app_purchase_provider.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/view/widget/game_card.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/provider/game_provider.dart';
import 'package:bebikame/view/widget/unable_game_card.dart';
import 'package:bebikame/view/dialog/confirmation_dialog.dart';
import 'package:bebikame/view/dialog/error_dialog.dart';
import 'package:bebikame/view/dialog/setting_dialog.dart';

class GameSelectionView extends ConsumerWidget {
  final _inAppPurchaseService = getIt<InAppPurchaseService>();

  GameSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isEnableInAppPurchase = ref.watch(isEnableInAppPurchaseProvider);

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
                await _handleSettingButtonPress(context, ref);
              } catch (e) {
                if (context.mounted) {
                  showErrorDialog(context, e.toString());
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
                return !isEnableInAppPurchase && (index == 4 || index == 5)
                    ? UnableGameCard(imagePath: game[index].image)
                    : GameCard(
                        imagePath: game[index].image,
                        isLocked: game[index].isLocked,
                        onTap: () async {
                          try {
                            await _handleGridTilePress(
                                context, ref, game[index]);
                          } catch (e) {
                            if (context.mounted) {
                              showErrorDialog(
                                context,
                                e.toString(),
                              );
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
    BuildContext context,
    WidgetRef ref,
    Game game,
  ) async {
    if (game.isLocked) {
      final result = await showConfirmationDialog(
        context: context,
        title: game.name,
        content: 'このゲームはロックされています。\n購入してロックを解除しますか？',
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

    if (context.mounted) await _goToGamePreviewView(context, ref, game);
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

  Future<void> _handleSettingButtonPress(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final sharedPrefService = getIt<SharedPreferencesService>();
    final savedShootingTime = await sharedPrefService.getShootingTime();
    if (context.mounted) {
      final result = await showSettingsDialog(
        context,
        savedShootingTime,
        () {
          ref.read(isEnableInAppPurchaseProvider.notifier).state = true;
          ref.read(gameProvider.notifier).updateGameLockStatus();
        },
      );
      if (result != null) {
        await sharedPrefService.saveShootingTime(result);
      }
    }
  }

  Future<void> _goToGamePreviewView(
    BuildContext context,
    WidgetRef ref,
    Game game,
  ) async {
    final audioService = getIt<AudioService>();
    await audioService.play('button_tap');
    ref.read(gameProvider.notifier).updateGameSelected(game.name);
    if (context.mounted) {
      context.push('/game_preview_view');
    }
  }
}
