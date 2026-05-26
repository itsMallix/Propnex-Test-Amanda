import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'package:propnex_take_home_test/core/providers/view_state_widget.dart';
import 'package:propnex_take_home_test/features/auth/presentation/providers/auth_providers.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/products/presentation/providers/product_providers.dart';
import 'package:propnex_take_home_test/features/products/presentation/widgets/product_card.dart';
import 'package:propnex_take_home_test/features/products/presentation/widgets/product_form_dialog.dart';
import 'package:propnex_take_home_test/features/products/presentation/widgets/product_skeleton.dart';
import 'package:propnex_take_home_test/features/products/presentation/screens/product_detail_screen.dart';
import 'package:propnex_take_home_test/features/favorites/presentation/providers/favorite_providers.dart';

class ProductScreen extends StatefulWidget {
  static const routeName = '/products';

  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _scrollCtr = ScrollController();
  final _searchCtr = TextEditingController();
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
    _scrollCtr.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtr.dispose();
    _searchCtr.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtr.position.pixels >=
        _scrollCtr.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    _searchCtr.clear();
    await context.read<ProductProvider>().fetchProducts(isRefresh: true);
  }

  void _openDetail(Product product) {
    context.read<ProductProvider>().selectProduct(product);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<ProductProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<FavoritesProvider>(),
            ),
          ],
          child: const ProductDetailScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await context.read<ProductProvider>().deleteProduct(
        product.id,
      );
      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductFormDialog.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const ProductSkeleton();
          }

          return ViewStateWidget(
            state: provider.state,
            errorMessage: provider.errorMessage,
            onRetry: provider.fetchProducts,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _ProductListView(
                products: provider.products,
                hasMore: provider.hasMore,
                loadingMore: provider.loadingMore,
                scrollCtr: _scrollCtr,
                onTap: _openDetail,
                onEdit: (p) => ProductFormDialog.show(context, product: p),
                onDelete: _confirmDelete,
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _searchOpen
          ? TextField(
              controller: _searchCtr,
              autofocus: true,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: 'Search products…',
                hintStyle: TextStyle(fontSize: 16.sp),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (v) =>
                  context.read<ProductProvider>().onSearchChanged(v),
            )
          : const Text('Products'),
      actions: [
        IconButton(
          icon: Icon(_searchOpen ? Icons.close_rounded : Icons.search_rounded),
          onPressed: () {
            setState(() => _searchOpen = !_searchOpen);
            if (!_searchOpen) {
              _searchCtr.clear();
              context.read<ProductProvider>().clearSearch();
            }
          },
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'logout') {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductListView extends StatelessWidget {
  final List<Product> products;
  final bool hasMore;
  final bool loadingMore;
  final ScrollController scrollCtr;
  final void Function(Product) onTap;
  final void Function(Product) onEdit;
  final void Function(Product) onDelete;

  const _ProductListView({
    required this.products,
    required this.hasMore,
    required this.loadingMore,
    required this.scrollCtr,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = products.length + (hasMore ? 1 : 0);

    return ListView.builder(
      controller: scrollCtr,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        if (index == products.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final product = products[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Dismissible(
            key: ValueKey(product.id),
            direction: DismissDirection.endToStart,
            background: _DeleteBackground(),
            confirmDismiss: (_) async {
              onDelete(product);
              return false;
            },
            child: ProductCard(
              product: product,
              onTap: () => onTap(product),
              trailingAction: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit(product);
                  if (v == 'delete') onDelete(product);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
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
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.delete_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 24.sp,
      ),
    );
  }
}
