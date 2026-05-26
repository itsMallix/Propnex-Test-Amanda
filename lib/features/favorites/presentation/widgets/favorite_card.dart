import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:propnex_take_home_test/core/utils/extensions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/favorites/domain/entities/favorite.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteCard({
    super.key,
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  void _share(Product p) {
    Share.share(
      '🛍️ ${p.title}\n💰 ${p.discountedPrice.toCurrency()}\n⭐ ${p.rating}\n\n${p.description}\n\nLink: ${p.thumbnail}',
      subject: p.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = favorite.product;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Hero(
                tag: 'fav-product-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    product.thumbnail,
                    width: 68.w,
                    height: 68.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 68.w,
                      height: 68.h,
                      color: context.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: context.colorScheme.outline,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.category.toUpperCase(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          letterSpacing: 0.5,
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          product.discountedPrice.toCurrency(),
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.star_rounded,
                          size: 13.sp,
                          color: AppTheme.warningColor,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Added ${_formatDate(favorite.addedAt)}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.outline,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Share',
                    icon: Icon(Icons.share_rounded, size: 20.sp),
                    onPressed: () => _share(product),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 8.h),
                  IconButton(
                    tooltip: 'Remove favorite',
                    icon: Icon(
                      Icons.favorite_rounded,
                      size: 20.sp,
                      color: AppTheme.errorColor,
                    ),
                    onPressed: onRemove,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
