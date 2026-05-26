import 'package:equatable/equatable.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';

class Favorite extends Equatable {
  final Product product;
  final DateTime addedAt;

  const Favorite({
    required this.product,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [product.id];
}
