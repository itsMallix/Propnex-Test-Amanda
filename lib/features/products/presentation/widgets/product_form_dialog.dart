import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'package:propnex_take_home_test/core/utils/validators.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/products/presentation/providers/product_providers.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  static Future<void> show(BuildContext context, {Product? product}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ProductProvider>(),
        child: ProductFormDialog(product: product),
      ),
    );
  }

  bool get isEditing => product != null;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtr;
  late final TextEditingController _descCtr;
  late final TextEditingController _priceCtr;
  late final TextEditingController _stockCtr;
  late final TextEditingController _brandCtr;
  late final TextEditingController _categoryCtr;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtr = TextEditingController(text: p?.title ?? '');
    _descCtr = TextEditingController(text: p?.description ?? '');
    _priceCtr = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _stockCtr = TextEditingController(
      text: p != null ? p.stock.toString() : '',
    );
    _brandCtr = TextEditingController(text: p?.brand ?? '');
    _categoryCtr = TextEditingController(text: p?.category ?? '');
  }

  @override
  void dispose() {
    _titleCtr.dispose();
    _descCtr.dispose();
    _priceCtr.dispose();
    _stockCtr.dispose();
    _brandCtr.dispose();
    _categoryCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final provider = context.read<ProductProvider>();
    bool success;

    if (widget.isEditing) {
      success = await provider.updateProduct(
        product: widget.product!,
        title: _titleCtr.text.trim(),
        description: _descCtr.text.trim(),
        price: double.parse(_priceCtr.text.trim()),
        stock: int.parse(_stockCtr.text.trim()),
        brand: _brandCtr.text.trim(),
        category: _categoryCtr.text.trim(),
      );
    } else {
      success = await provider.createProduct(
        title: _titleCtr.text.trim(),
        description: _descCtr.text.trim(),
        price: double.parse(_priceCtr.text.trim()),
        stock: int.parse(_stockCtr.text.trim()),
        brand: _brandCtr.text.trim(),
        category: _categoryCtr.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Product updated!' : 'Product added!',
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                widget.isEditing ? 'Edit Product' : 'Add Product',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 20.h),

              _field(
                controller: _titleCtr,
                label: 'Title',
                icon: Icons.title_rounded,
                action: TextInputAction.next,
                validator: (v) =>
                    Validators.minLength(v, 3, fieldName: 'Title'),
              ),
              _field(
                controller: _descCtr,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 3,
                action: TextInputAction.next,
                validator: (v) =>
                    Validators.minLength(v, 10, fieldName: 'Description'),
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _priceCtr,
                      label: 'Price (\$)',
                      icon: Icons.attach_money_rounded,
                      inputType: TextInputType.number,
                      action: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: Validators.price,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _stockCtr,
                      label: 'Stock',
                      icon: Icons.inventory_2_outlined,
                      inputType: TextInputType.number,
                      action: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          Validators.notEmpty(v, fieldName: 'Stock'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _field(
                controller: _brandCtr,
                label: 'Brand',
                icon: Icons.branding_watermark_outlined,
                action: TextInputAction.next,
                validator: (v) => Validators.notEmpty(v, fieldName: 'Brand'),
              ),
              _field(
                controller: _categoryCtr,
                label: 'Category',
                icon: Icons.category_outlined,
                action: TextInputAction.done,
                validator: (v) => Validators.notEmpty(v, fieldName: 'Category'),
              ),
              const SizedBox(height: 8),

              Consumer<ProductProvider>(
                builder: (_, provider, _) => FilledButton(
                  onPressed: provider.isBusy ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: provider.isBusy
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5.w,
                            color: AppTheme.whiteSpaceColor,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Save Changes' : 'Add Product',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputAction action = TextInputAction.next,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: controller,
        textInputAction: action,
        keyboardType: inputType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(fontSize: 16.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14.sp),
          prefixIcon: Icon(icon, size: 20.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
