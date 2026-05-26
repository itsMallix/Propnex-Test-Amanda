import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class ProductSkeleton extends StatelessWidget {
  final int count;

  const ProductSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemBuilder: (_, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    color: AppTheme.whiteSpaceColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(double.infinity, 14.h),
                      SizedBox(height: 4.h),
                      _box(60.w, 11.sp),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          _box(50.w, 14.sp),
                          SizedBox(width: 6.w),
                          _box(40.w, 12.sp),
                          SizedBox(width: 4.w),
                          _box(30.w, 12.sp),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _box(14.sp, 14.sp),
                          SizedBox(width: 2.w),
                          _box(20.w, 12.sp),
                          SizedBox(width: 8.w),
                          _box(14.sp, 14.sp),
                          SizedBox(width: 2.w),
                          _box(80.w, 12.sp),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _box(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppTheme.whiteSpaceColor,
      borderRadius: BorderRadius.circular(4.r),
    ),
  );
}
