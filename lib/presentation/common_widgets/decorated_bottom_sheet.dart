import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

/// Beautiful, reusable bottom sheet with consistent styling
class DecoratedBottomSheet {
  /// Show a decorated bottom sheet with custom content
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: AppTheme.spacingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title if provided
            if (title != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: AppTheme.spacingL),
            ] else
              const SizedBox(height: AppTheme.spacingS),
            
            // Content
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  /// Show a list-style bottom sheet with options
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption<T>> options,
  }) {
    return show<T>(
      context: context,
      title: title,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return _OptionTile<T>(option: option);
        },
      ),
    );
  }
}

/// Option item for bottom sheet
class BottomSheetOption<T> {
  final IconData icon;
  final String label;
  final T value;
  final Color? iconColor;
  final VoidCallback? onTap;

  const BottomSheetOption({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
  });
}

class _OptionTile<T> extends StatelessWidget {
  final BottomSheetOption<T> option;

  const _OptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: (option.iconColor ?? AppTheme.accentColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(
            option.icon,
            color: option.iconColor ?? AppTheme.accentColor,
            size: 24,
          ),
        ),
        title: Text(
          option.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.pop(context, option.value);
          option.onTap?.call();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }
}
