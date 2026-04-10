import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'product_detail_page.dart';
import '../viewmodels/product_viewmodel.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos (${vm.favoriteCount} favoritos)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Somente favoritos'),
                const SizedBox(width: 8),
                Switch(
                  value: vm.showFavoritesOnly,
                  onChanged: vm.setShowFavoritesOnly,
                ),
              ],
            ),
          )
        ],
      ),
      body: () {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(vm.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.loadProducts,
                    child: const Text('Tentar novamente'),
                  )
                ],
              ),
            ),
          );
        }

        if (vm.visibleProducts.isEmpty) {
          return Center(
            child: Text(
              vm.showFavoritesOnly
                  ? 'Nenhum favorito encontrado.'
                  : 'Nenhum produto encontrado.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: vm.visibleProducts.length,
          itemBuilder: (context, index) {
            final product = vm.visibleProducts[index];
            return Card(
              color: product.favorite ? Colors.amber.withOpacity(0.15) : null,
              child: ListTile(
                leading: Image.network(
                  product.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(product.title),
                subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                trailing: IconButton(
                  onPressed: () => vm.toggleFavorite(product.id),
                  tooltip: product.favorite
                      ? 'Remover dos favoritos'
                      : 'Favoritar',
                  icon: Icon(
                    product.favorite ? Icons.star : Icons.star_border,
                    color: product.favorite ? Colors.amber : null,
                  ),
                ),
              ),
            );
          },
        );
      }(),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.loadProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
