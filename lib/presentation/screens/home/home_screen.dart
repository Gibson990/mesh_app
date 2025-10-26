import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mesh_app/core/constants/app_constants.dart';
import 'package:mesh_app/presentation/common_widgets/custom_app_bar.dart';
import 'package:mesh_app/presentation/common_widgets/blur_modal.dart';
import 'package:mesh_app/presentation/screens/media_tab/media_tab_screen.dart';
import 'package:mesh_app/presentation/screens/threads_tab/threads_tab_screen.dart';
import 'package:mesh_app/presentation/screens/updates_tab/updates_tab_screen.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/services/app_state_provider.dart';
import 'package:mesh_app/services/bluetooth/bluetooth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppStateProvider>(context, listen: true);
    
    // Update tab controller based on access level
    if (appState.isHigherAccess && _tabController.length == 2) {
      final oldController = _tabController;
      _tabController = TabController(length: 3, vsync: this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController.dispose();
      });
    } else if (!appState.isHigherAccess && _tabController.length == 3) {
      final oldController = _tabController;
      _tabController = TabController(length: 2, vsync: this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController.dispose();
      });
    }
  }

  void _handleLogin() {
    _showLoginDialog();
  }

  void _showLoginDialog() {
    final userIdController = TextEditingController();
    final passwordController = TextEditingController();
    bool _obscurePassword = true;

    BlurModalHelper.showFullScreenBlurModal(
      context: context,
      isDismissible: false, // Prevent accidental dismissal
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingXL,
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingL,
            ),
            child: Column(
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Login form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.2).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentColor,
                                  AppTheme.primaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Higher-Access Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingXS),
                                Text(
                                  'Enter your verified credentials',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                      // Form fields
                      TextField(
                        controller: userIdController,
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusM),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setModalState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusM),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.spacingM),
                                side:
                                    const BorderSide(color: AppTheme.textHint),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusM),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final userId = userIdController.text.trim();
                                final password = passwordController.text.trim();

                                // Verify credentials exist
                                if (AppConstants.defaultAdminPasswordHashes
                                        .containsKey(userId)) {
                                  Navigator.pop(context);
                                  
                                  // Use state provider for login (handles password hashing)
                                  final appState = Provider.of<AppStateProvider>(context, listen: false);
                                  final success = await appState.loginHigherAccess(userId, password);
                                  
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.verified,
                                              color: AppTheme.verifiedBadge,
                                            ),
                                            const SizedBox(
                                                width: AppTheme.spacingS),
                                            const Text(
                                                'Login successful! You now have verified access.'),
                                          ],
                                        ),
                                        backgroundColor: AppTheme.accentColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusM),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Invalid credentials. Please try again.'),
                                        backgroundColor: AppTheme.errorColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusM),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.spacingM),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusM),
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        onLoginPressed: _handleLogin,
        tabController: _tabController,
        isHigherAccess: appState.isHigherAccess,
        onSearchPressed: () {
          _showSearchDialog();
        },
        onPeersPressed: () {
          _showPeersDialog();
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ThreadsTabScreen(),
          const MediaTabScreen(),
          if (appState.isHigherAccess) const UpdatesTabScreen(),
        ],
      ),
    );
  }

  void _showPeersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bluetooth, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'Bluetooth Peers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Discovered devices nearby',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _bluetoothService.discoveredDevicesStream,
                builder: (context, snapshot) {
                  final devices = snapshot.data ?? [];
                  
                  if (devices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 64,
                            color: AppTheme.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No devices found',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scanning for nearby devices...',
                            style: TextStyle(
                              color: AppTheme.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final rssi = device['rssi'] as int? ?? -100;
                      final signalStrength = rssi > -70 ? 'Strong' : rssi > -85 ? 'Medium' : 'Weak';
                      final signalColor = rssi > -70 ? Colors.green : rssi > -85 ? Colors.orange : Colors.red;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withAlpha((255 * 0.1).round()),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.devices,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          title: Text(device['name'] ?? 'Unknown Device'),
                          subtitle: Text(
                            device['id'] ?? 'Unknown ID',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.signal_cellular_alt,
                                size: 16,
                                color: signalColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                signalStrength,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: signalColor,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connecting to ${device['name'] ?? 'device'}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scanning for devices...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search & Filter',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            // Location filter
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Filter by Location'),
              subtitle: const Text('Show messages from specific cities'),
              onTap: () {
                Navigator.pop(context);
                _showLocationFilter();
              },
            ),
            // Coordinator filter
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Coordinator Messages Only'),
              subtitle: const Text('Show verified announcements'),
              onTap: () {
                Navigator.pop(context);
                _showCoordinatorFilter();
              },
            ),
            // Search text
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Messages'),
              subtitle: const Text('Find specific content'),
              onTap: () {
                Navigator.pop(context);
                _showTextSearch();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter() {
    // TODO: Implement location-based filtering
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location filter coming soon')),
    );
  }

  void _showCoordinatorFilter() {
    // TODO: Implement coordinator-only filtering
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coordinator filter coming soon')),
    );
  }

  void _showTextSearch() {
    // TODO: Implement text search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text search coming soon')),
    );
  }

  void _showNewMessageOptions() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Create New',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Text Message'),
              subtitle: const Text('Send a text message to threads'),
              onTap: () {
                Navigator.pop(context);
                // Switch to threads tab
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Photo/Video'),
              subtitle: const Text('Share media with the network'),
              onTap: () {
                Navigator.pop(context);
                // Switch to media tab
                _tabController.animateTo(1);
              },
            ),
            if (appState.isHigherAccess)
              ListTile(
                leading: Icon(
                  Icons.campaign,
                  color: AppTheme.verifiedBadge,
                ),
                title: Text(
                  'Official Update',
                  style: TextStyle(color: AppTheme.verifiedBadge),
                ),
                subtitle: const Text('Post a verified announcement'),
                onTap: () {
                  Navigator.pop(context);
                  // Switch to updates tab
                  _tabController.animateTo(2);
                },
              ),
          ],
        ),
      ),
    );
  }
}
