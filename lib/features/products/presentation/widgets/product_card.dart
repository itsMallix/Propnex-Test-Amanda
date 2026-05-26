import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:propnex_take_home_test/core/utils/extensions.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final Widget? trailingAction;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Hero(
                tag: 'product-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    product.thumbnail,
                    width: 72.w,
                    height: 72.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 72.w,
                      height: 72.h,
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
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      product.category.capitalize(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.primary,
                        letterSpacing: 0.5,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
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
                        if (product.discountPercentage > 0) ...[
                          SizedBox(width: 6.w),
                          Text(
                            product.price.toCurrency(),
                            style: context.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: context.colorScheme.outline,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}%',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.error,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: AppTheme.warningColor,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          product.isAvailable
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 14.sp,
                          color: product.isAvailable
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          product.isAvailable
                              ? 'In stock (${product.stock})'
                              : 'Out of stock',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: product.isAvailable
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ?trailingAction,
            ],
          ),
        ),
      ),
    );
  }
}
