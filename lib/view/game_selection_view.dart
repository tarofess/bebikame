import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/view/game_preview_view.dart';
import 'package:bebikame/view/widget/game_card.dart';
import 'package:bebikame/viewmodel/provider/game_provider.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameSelectionView extends ConsumerWidget {
  final _navigationService = getIt<NavigationService>();
  final _dialogService = getIt<DialogService>();
  final _audioService = getIt<AudioService>();
  final _sharedPrefService = getIt<SharedPreferencesService>();

  GameSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ゲームを選んでね！'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              try {
                await _handleSettingButtonPress(context, _sharedPrefService);
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
                  imagePath: game[index]['image']!,
                  onTap: () async {
                    try {
                      await _handleGridTilePress(context, ref, index);
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
      BuildContext context, WidgetRef ref, int index) async {
    await _audioService.play('button_tap');
    ref.read(selectedGameProvider.notifier).state = index;
    if (context.mounted) {
      _navigationService.push(context, GamePreviewView());
    }
  }

  Future<void> _handleSettingButtonPress(
      BuildContext context, SharedPreferencesService sharedPrefService) async {
    final savedShootingTime = await sharedPrefService.getShootingTime();
    if (context.mounted) {
      final result =
          await _dialogService.showSettingsDialog(context, savedShootingTime);
      if (result != null) {
        await sharedPrefService.saveShootingTime(result);
      }
    }
  }
}
