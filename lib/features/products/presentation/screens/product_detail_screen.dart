import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/constants/app_strings.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:propnex_take_home_test/core/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:propnex_take_home_test/features/products/presentation/providers/product_providers.dart';
import 'package:propnex_take_home_test/features/products/presentation/widgets/product_form_dialog.dart';
import 'package:propnex_take_home_test/features/favorites/presentation/providers/favorite_providers.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final product = provider.selected;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('No product selected.')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280.h,
                pinned: true,
                actions: [
                  Consumer<FavoritesProvider>(
                    builder: (_, favProvider, _) {
                      final isFav = favProvider.isFavorite(product.id);
                      return IconButton(
                        tooltip: isFav ? 'Remove favorite' : 'Add favorite',
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isFav),
                            color: isFav ? AppTheme.errorColor : null,
                          ),
                        ),
                        onPressed: () => favProvider.toggleFavorite(product),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Share',
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () => _shareProduct(product),
                  ),
                  IconButton(
                    tooltip: AppStrings.editProduct,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        ProductFormDialog.show(context, product: product),
                  ),
                  IconButton(
                    tooltip: AppStrings.deleteProduct,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDelete(context, provider),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product-${product.id}',
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 64.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(product.category.capitalize()),
                        labelStyle: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          letterSpacing: 0.5,
                          fontSize: 11.sp,
                        ),
                        backgroundColor: context.colorScheme.primaryContainer,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        product.title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'by ${product.brand}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            product.discountedPrice.toCurrency(),
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 28.sp,
                            ),
                          ),
                          if (product.discountPercentage > 0) ...[
                            SizedBox(width: 10.w),
                            Text(
                              product.price.toCurrency(),
                              style: context.textTheme.titleMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: context.colorScheme.outline,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _StatsRow(product: product),
                      SizedBox(height: 20.h),
                      Text(
                        'Description',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        product.description,
                        style: context.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      if (product.images.isNotEmpty) ...[
                        Text(
                          'Gallery',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 100.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: product.images.length,
                            separatorBuilder: (_, _) => SizedBox(width: 8.w),
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                product.images[i],
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareProduct(dynamic product) {
    final text =
        '''
🛍️ ${product.title}
💰 ${product.discountedPrice.toCurrency()}
⭐ ${product.rating} · ${product.category.capitalize()}

${product.description}
''';
    Share.share(text, subject: product.title as String);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductProvider provider,
  ) async {
    final product = provider.selected!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final ok = await provider.deleteProduct(product.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Product deleted.' : 'Failed to delete.'),
            backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic product;

  const _StatsRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            icon: Icons.star_rounded,
            color: AppTheme.warningColor,
            label: 'Rating',
            value: product.rating.toStringAsFixed(1),
          ),
          _Divider(),
          _Stat(
            icon: Icons.inventory_2_outlined,
            color: product.isAvailable
                ? AppTheme.successColor
                : AppTheme.errorColor,
            label: 'Stock',
            value: '${product.stock}',
          ),
          _Divider(),
          _Stat(
            icon: Icons.discount_outlined,
            color: context.colorScheme.error,
            label: 'Discount',
            value: '${product.discountPercentage.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 40.h,
      color: context.colorScheme.outlineVariant,
    );
  }
}
