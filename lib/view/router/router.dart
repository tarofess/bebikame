import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/view/game_preview_view.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:bebikame/view/game_view.dart';
import 'package:bebikame/view/video_preview_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => GameSelectionView(),
      ),
      GoRoute(
        path: '/game_preview_view',
        builder: (context, state) => GamePreviewView(),
      ),
      GoRoute(
        path: '/game_view',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage(
            child: GameView(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.fastLinearToSlowEaseIn;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/video_preview_view',
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          final videoPath = extra['videoPath'] as String;
          return VideoPreviewView(videoPath: videoPath);
        },
      ),
    ],
  );
});
