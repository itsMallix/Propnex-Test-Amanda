import 'package:flutter/material.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No data found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or check back later.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty ? message : 'An unexpected error occurred.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
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
