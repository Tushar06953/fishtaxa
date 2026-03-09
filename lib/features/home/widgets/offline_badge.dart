import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.biolum,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 600.ms)
            .then()
            .fadeOut(duration: 600.ms),
        const SizedBox(width: 6),
        Text(
          'OFFLINE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.biolum,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
