import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_detail_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.read<AuthViewModel>();
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }

    if (_didLoad) return;
    _didLoad = true;
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
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: vm.visibleProducts.length,
          itemBuilder: (context, index) {
            final product = vm.visibleProducts[index];
            return Card(
              color: product.favorite ? Theme.of(context).colorScheme.secondaryContainer : null,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product_image_${product.id}',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'R\$ ${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(16),
                      onPressed: () => vm.toggleFavorite(product.id),
                      tooltip: product.favorite ? 'Remover dos favoritos' : 'Favoritar',
                      icon: Icon(
                        product.favorite ? Icons.favorite : Icons.favorite_border,
                        color: product.favorite ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => vm.loadProducts(forceRefresh: true),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}