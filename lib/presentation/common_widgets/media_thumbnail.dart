import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class MediaThumbnail extends StatelessWidget {
  final String type;
  final String? duration;
  final double? aspectRatio;
  final VoidCallback? onTap;
  final bool showLoadingShimmer;

  const MediaThumbnail({
    super.key,
    required this.type,
    this.duration,
    this.aspectRatio,
    this.onTap,
    this.showLoadingShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          color: AppTheme.surfaceVariant,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Stack(
            children: [
              // Main content
              Positioned.fill(
                child: _buildContent(),
              ),
              // Duration badge
              if (duration != null)
                Positioned(
                  bottom: AppTheme.spacingS,
                  right: AppTheme.spacingS,
                  child: _buildDurationBadge(),
                ),
              // Media type indicator
              Positioned(
                top: AppTheme.spacingS,
                left: AppTheme.spacingS,
                child: _buildTypeIndicator(),
              ),
              // Loading shimmer
              if (showLoadingShimmer)
                Positioned.fill(
                  child: _buildLoadingShimmer(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (type) {
      case 'image':
        return _buildImageContent();
      case 'video':
        return _buildVideoContent();
      case 'audio':
        return _buildAudioContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildImageContent() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.image,
          size: 48,
          color: AppTheme.textHint,
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 48,
              color: AppTheme.textHint,
            ),
          ),
          // Play button overlay
          const Center(
            child: Icon(
              Icons.play_arrow,
              size: 32,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.graphic_eq,
          size: 48,
          color: AppTheme.accentColor,
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.insert_drive_file,
          size: 48,
          color: AppTheme.textHint,
        ),
      ),
    );
  }

  Widget _buildDurationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((255 * 0.7).round()),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        duration!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXS),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((255 * 0.6).round()),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Icon(
        _getTypeIcon(),
        size: 16,
        color: Colors.white,
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildLoadingShimmer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceVariant,
            AppTheme.surfaceVariant.withAlpha((255 * 0.5).round()),
            AppTheme.surfaceVariant,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
        ),
      ),
    );
  }
}
