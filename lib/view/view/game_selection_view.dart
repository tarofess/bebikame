import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/model/game.dart';
import 'package:bebikame/application/provider/is_enable_in_app_purchase_provider.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/view/widget/game_card.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/application/provider/game_notifier.dart';
import 'package:bebikame/view/widget/unable_game_card.dart';
import 'package:bebikame/view/dialog/confirmation_dialog.dart';
import 'package:bebikame/view/dialog/error_dialog.dart';
import 'package:bebikame/view/dialog/setting_dialog.dart';
import 'package:bebikame/model/result.dart';
import 'package:bebikame/view/provider/buy_game_usecase_provider.dart';
import 'package:bebikame/view/dialog/parental_gate_dialog.dart';

class GameSelectionView extends ConsumerWidget {
  const GameSelectionView({super.key});

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
              await _showSettings(context, ref);
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
                          await _handleGameSelect(
                            context,
                            ref,
                            game[index],
                          );
                        },
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGameSelect(
    BuildContext context,
    WidgetRef ref,
    Game game,
  ) async {
    if (!game.isLocked) {
      await _goToGamePreviewView(context, ref, game);
      return;
    }

    // 未購入の有料ゲームの場合
    if (context.mounted) {
      final isConfirmed = await showConfirmationDialog(
        context: context,
        title: game.name,
        content: 'このゲームはロックされています。\n購入してロックを解除しますか？',
      );
      if (!isConfirmed || !context.mounted) return;

      // 保護者かどうかを確認
      final parentalGateResult = await showParentalGateDialog(context: context);
      if (parentalGateResult is Failure) {
        if (context.mounted) {
          showErrorDialog(context, parentalGateResult.message);
        }
        return;
      }

      // 保護者であれば購入処理
      if (context.mounted) {
        final result = await LoadingOverlay.of(context).during(
          () => ref.read(buyGameUsecaseProvider).execute(game),
        );

        if (result == null) return;

        switch (result) {
          case Success():
            break;
          case Failure(message: final message):
            if (context.mounted) showErrorDialog(context, message);
            break;
        }
      }
    }
  }

  Future<void> _showSettings(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
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
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(context, e.toString());
      }
    }
  }

  Future<void> _goToGamePreviewView(
    BuildContext context,
    WidgetRef ref,
    Game game,
  ) async {
    try {
      final audioService = getIt<AudioService>();
      await audioService.play('button_tap');

      ref.read(gameProvider.notifier).updateGameSelected(game.name);
      if (context.mounted) context.push('/game_preview_view');
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(context, e.toString());
      }
    }
  }
}
