import 'package:flutter/material.dart';

class GameSelectionView extends StatelessWidget {
  const GameSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Game Selection'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Select a game to play'),
          ],
        ),
      ),
    );
  }
}
