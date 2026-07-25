import 'package:flutter/material.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

/// Shared loading primitives that preserve the space occupied by real content.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final position = reduceMotion ? 0.0 : (_controller.value * 2) - 1;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment(position - 1, 0),
                end: Alignment(position + 1, 0),
                colors: const [
                  AppColors.borderSoft,
                  AppColors.scaffoldBg,
                  AppColors.borderSoft,
                ],
                stops: const [0.15, 0.5, 0.85],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 132,
    this.gap = 12,
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final double itemHeight;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading content',
      liveRegion: true,
      child: Padding(
        padding: padding,
        child: Column(
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == itemCount - 1 ? 0 : gap,
              ),
              child: AppSkeleton(height: itemHeight),
            ),
          ),
        ),
      ),
    );
  }
}

class AppPageLoader extends StatelessWidget {
  const AppPageLoader({super.key, this.message = 'Loading…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message,
        liveRegion: true,
        child: const SizedBox.square(
          dimension: 44,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

class AppInlineLoader extends StatelessWidget {
  const AppInlineLoader({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
