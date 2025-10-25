import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/presentation/screens/media_tab/media_viewer_screen.dart';

class MediaTabScreen extends StatefulWidget {
  const MediaTabScreen({super.key});

  @override
  State<MediaTabScreen> createState() => _MediaTabScreenState();
}

class _MediaTabScreenState extends State<MediaTabScreen> {
  final List<Map<String, dynamic>> _mediaItems = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDummyMedia();
  }

  void _loadDummyMedia() {
    // Add dummy media items
    _mediaItems.addAll([
      {
        'type': 'image',
        'sender': 'Alice',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'caption': 'Check out this view!',
      },
      {
        'type': 'audio',
        'sender': 'Bob',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'duration': '0:12',
      },
      {
        'type': 'video',
        'sender': 'Charlie',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'caption': 'Quick update from the field',
        'duration': '0:14',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Column(
      children: [
        // Floating filter button
        _buildFloatingFilter(),
        // Media grid
        Expanded(
          child: filteredItems.isEmpty
              ? _buildEmptyState()
              : _buildMediaGrid(filteredItems),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedFilter == 'All') {
      return _mediaItems;
    }
    return _mediaItems
        .where((item) =>
            item['type'] == _selectedFilter.toLowerCase().replaceAll('s', ''))
        .toList();
  }

  Widget _buildFloatingFilter() {
    final filters = ['All', 'Images', 'Videos', 'Audio'];

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingS),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: AnimatedContainer(
                  duration: AppTheme.shortAnimation,
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentColor.withAlpha((255 * 0.1).round())
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textHint.withAlpha((255 * 0.3).round()),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                      ],
                      Text(
                        filter,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.accentColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingS,
        mainAxisSpacing: AppTheme.spacingS,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMediaCard(items[index], index);
      },
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaViewerScreen(
              mediaItems: _getFilteredItems(),
              initialIndex: index,
              senderName: item['sender'],
              timestamp: item['timestamp'],
              caption: item['caption'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          color: AppTheme.surfaceColor,
          border: Border.all(
            color: AppTheme.messageBorder,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Stack(
            children: [
              // Media preview
              Positioned.fill(
                child: _buildMediaPreview(item['type']),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((255 * 0.6).round()),
                      ],
                    ),
                  ),
                ),
              ),
              // Media type indicator
              Positioned(
                top: AppTheme.spacingS,
                right: AppTheme.spacingS,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.7).round()),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMediaIcon(item['type']),
                        size: 12,
                        color: Colors.white,
                      ),
                      if (item['duration'] != null) ...[
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          item['duration'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sender info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppTheme.accentColor,
                            child: Text(
                              item['sender'][0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              item['sender'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item['caption'] != null &&
                          item['caption'].isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          item['caption'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMediaIcon(String type) {
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

  Widget _buildMediaPreview(String type) {
    switch (type) {
      case 'image':
        return Container(
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Icon(
              Icons.image,
              size: 40,
              color: AppTheme.textHint,
            ),
          ),
        );
      case 'video':
        return Container(
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 40,
              color: AppTheme.textHint,
            ),
          ),
        );
      case 'audio':
        return Container(
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Icon(
              Icons.graphic_eq,
              size: 40,
              color: AppTheme.accentColor,
            ),
          ),
        );
      default:
        return Container(
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Icon(
              Icons.insert_drive_file,
              size: 40,
              color: AppTheme.textHint,
            ),
          ),
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.perm_media_outlined,
              size: 40,
              color: AppTheme.textHint,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No media yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Share images, audio, and videos with your network',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          ElevatedButton.icon(
            onPressed: () {
              _showMediaOptions();
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Media'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open gallery
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Record Audio (15s max)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Record audio
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video (15s max)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Record video
              },
            ),
          ],
        ),
      ),
    );
  }
}
