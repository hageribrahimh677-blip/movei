import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/movie.dart';

class MoviePosterCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MoviePosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ التقييم فوق البوستر في سطر لوحده - زي السكرين شوت بالظبط
          if (movie.rating > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star,
                      color: AppColors.primaryYellow, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // البوستر - بياخد باقي المساحة، مفيش اسم فيلم تحته
          // (الاسم موجود جوه البوستر نفسه زي السكرين شوت)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox.expand(
                child: movie.mediumCoverImage.isEmpty
                    ? Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.movie,
                      color: AppColors.textGrey, size: 32),
                )
                    : Image.network(
                  movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) => Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.broken_image,
                        color: AppColors.textGrey, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}