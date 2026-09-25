import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';

Future<void> launchTrailer(BuildContext context, String ytTrailerCode) async {
  if (ytTrailerCode.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('مفيش تريلر متاح للفيلم ده حاليًا')),
    );
    return;
  }

  final uri = Uri.parse('https://www.youtube.com/watch?v=$ytTrailerCode');

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('مقدرناش نفتح التريلر'),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }
}