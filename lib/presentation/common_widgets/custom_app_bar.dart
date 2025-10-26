import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onLoginPressed;
  final TabController tabController;
  final bool isHigherAccess;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onPeersPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onLoginPressed,
    required this.tabController,
    required this.isHigherAccess,
    this.onSearchPressed,
    this.onPeersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar with title and actions
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bluetooth),
                    tooltip: 'Bluetooth Peers',
                    onPressed: onPeersPressed ?? () {},
                    color: AppTheme.accentColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                    onPressed: onSearchPressed ?? () {},
                    color: AppTheme.textPrimary,
                  ),
                  if (!isHigherAccess)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor
                            .withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        tooltip: 'Higher-Access Login',
                        onPressed: onLoginPressed,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  if (isHigherAccess)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.verifiedBadge
                            .withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.verifiedBadge,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppTheme.verifiedBadge,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.verifiedBadge,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More options',
                    onPressed: () {
                      _showMoreOptions(context);
                    },
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
            ),
            // TabBar
            TabBar(
              controller: tabController,
              tabs: [
                const Tab(text: 'THREADS'),
                const Tab(text: 'MEDIA'),
                if (isHigherAccess)
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('UPDATES'),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.verifiedBadge,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Bluetooth Status'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show Bluetooth status
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Mesh'),
        content: const Text(
          'Mesh is a decentralized, protest-proof chat application.\n\n'
          'Version: 1.0.0\n\n'
          'Features:\n'
          '• Bluetooth mesh networking\n'
          '• End-to-end encryption\n'
          '• No central servers\n'
          '• Anonymous by default',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight + 16);
}
