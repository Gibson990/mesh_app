import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class FilterChipGroup extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String>? onChanged;
  final bool allowMultiple;
  final List<String>? selectedOptions;
  final ValueChanged<List<String>>? onMultipleChanged;
  final Axis direction;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const FilterChipGroup({
    super.key,
    required this.options,
    this.selectedOption,
    this.onChanged,
    this.allowMultiple = false,
    this.selectedOptions,
    this.onMultipleChanged,
    this.direction = Axis.horizontal,
    this.padding,
    this.spacing = AppTheme.spacingS,
  });

  @override
  State<FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends State<FilterChipGroup>
    with TickerProviderStateMixin {
  late List<String> _selectedOptions;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedOptions = widget.allowMultiple
        ? (widget.selectedOptions ?? [])
        : (widget.selectedOption != null ? [widget.selectedOption!] : []);

    _animationController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(FilterChipGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allowMultiple) {
      if (widget.selectedOptions != oldWidget.selectedOptions) {
        _selectedOptions = List.from(widget.selectedOptions ?? []);
      }
    } else {
      if (widget.selectedOption != oldWidget.selectedOption) {
        _selectedOptions =
            widget.selectedOption != null ? [widget.selectedOption!] : [];
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingM),
      child: widget.direction == Axis.horizontal
          ? _buildHorizontalLayout()
          : _buildVerticalLayout(),
    );
  }

  Widget _buildHorizontalLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.options.map((option) {
          return Padding(
            padding: EdgeInsets.only(
              right: option == widget.options.last ? 0 : widget.spacing,
            ),
            child: _buildFilterChip(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.options.map((option) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: option == widget.options.last ? 0 : widget.spacing,
          ),
          child: _buildFilterChip(option),
        );
      }).toList(),
    );
  }

  Widget _buildFilterChip(String option) {
    final isSelected = _selectedOptions.contains(option);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _handleSelection(option),
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
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                  ],
                  Text(
                    option,
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
      },
    );
  }

  void _handleSelection(String option) {
    setState(() {
      if (widget.allowMultiple) {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
        widget.onMultipleChanged?.call(_selectedOptions);
      } else {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.clear();
        } else {
          _selectedOptions = [option];
        }
        widget.onChanged
            ?.call(_selectedOptions.isNotEmpty ? _selectedOptions.first : '');
      }
    });

    if (_selectedOptions.contains(option)) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }
}

class AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Duration animationDuration;

  const AnimatedFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.animationDuration = AppTheme.shortAnimation,
  });

  @override
  State<AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _colorAnimation = ColorTween(
      begin: widget.unselectedColor ?? AppTheme.surfaceVariant,
      end: widget.selectedColor ??
          AppTheme.accentColor.withAlpha((255 * 0.1).round()),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(
                  color: widget.isSelected
                      ? (widget.selectedColor ?? AppTheme.accentColor)
                      : AppTheme.textHint.withAlpha((255 * 0.3).round()),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isSelected) ...[
                    Icon(
                      Icons.check,
                      size: 16,
                      color: widget.selectedColor ?? AppTheme.accentColor,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isSelected
                          ? (widget.selectedColor ?? AppTheme.accentColor)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
