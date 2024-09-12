import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                '処理中です...',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
