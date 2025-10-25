import 'package:flutter/material.dart';
import 'package:mesh_app/core/constants/app_constants.dart';
import 'package:mesh_app/presentation/common_widgets/custom_app_bar.dart';
import 'package:mesh_app/presentation/common_widgets/blur_modal.dart';
import 'package:mesh_app/presentation/screens/media_tab/media_tab_screen.dart';
import 'package:mesh_app/presentation/screens/threads_tab/threads_tab_screen.dart';
import 'package:mesh_app/presentation/screens/updates_tab/updates_tab_screen.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isHigherAccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                              onPressed: () {
                                final userId = userIdController.text.trim();
                                final password = passwordController.text.trim();

                                // Verify credentials
                                if (AppConstants.higherAccessCredentials
                                        .containsKey(userId) &&
                                    AppConstants
                                            .higherAccessCredentials[userId] ==
                                        password) {
                                  setState(() {
                                    _isHigherAccess = true;
                                    _tabController.dispose();
                                    _tabController =
                                        TabController(length: 3, vsync: this);
                                  });
                                  Navigator.pop(context);
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
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        onLoginPressed: _handleLogin,
        tabController: _tabController,
        isHigherAccess: _isHigherAccess,
        onSearchPressed: () {
          // TODO: Implement search
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search feature coming soon')),
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ThreadsTabScreen(),
          const MediaTabScreen(),
          if (_isHigherAccess) const UpdatesTabScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewMessageOptions();
        },
        tooltip: 'New Message',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _showNewMessageOptions() {
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
            if (_isHigherAccess)
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
