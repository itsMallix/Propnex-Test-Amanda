import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:propnex_take_home_test/core/utils/extensions.dart';
import 'base_provider.dart';

class ViewStateWidget extends StatelessWidget {
  final ViewState state;
  final String errorMessage;
  final VoidCallback? onRetry;
  final Widget child;
  final Widget? emptyWidget;
  final Widget? loadingWidget;

  const ViewStateWidget({
    super.key,
    required this.state,
    required this.child,
    this.errorMessage = '',
    this.onRetry,
    this.emptyWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewState.loading => loadingWidget ?? const _DefaultLoadingWidget(),
      ViewState.empty => emptyWidget ?? const _DefaultEmptyWidget(),
      ViewState.error => _DefaultErrorWidget(
        message: errorMessage,
        onRetry: onRetry,
      ),
      _ => child,
    };
  }
}

class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _DefaultEmptyWidget extends StatelessWidget {
  const _DefaultEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 50.sp,
                  color: context.colorScheme.outline,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No data found',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.outline,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Try a different search or check back later.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.outline,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 72.sp,
                  color: context.colorScheme.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Oops! Something went wrong',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  message.isNotEmpty ? message : 'An unexpected error occurred.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.outline,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  SizedBox(height: 24.h),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh_rounded, size: 18.sp),
                    label: Text('Try Again', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class BusyOverlay extends StatelessWidget {
  final bool isBusy;
  final Widget child;

  const BusyOverlay({super.key, required this.isBusy, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isBusy)
          Container(
            color: AppTheme.blackSpaceColor,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
