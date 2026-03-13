import 'package:flutter/material.dart';
import '../viewmodels/product_state.dart';
import '../viewmodels/product_viewmodel.dart';

class ProductPage extends StatefulWidget {
  final ProductViewModel viewModel;

  const ProductPage({super.key, required this.viewModel});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products - Atividade 2")),
      body: ValueListenableBuilder<ProductState>(
        valueListenable: widget.viewModel.state,
        builder: (context, state, _) {
          // 1. Estado: Carregando
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Estado: Erro
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(state.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.viewModel.loadProducts,
                      child: const Text('Tentar Novamente'),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Estado: Sucesso (Lista Vazia)
          if (state.products.isEmpty) {
            return const Center(child: Text("Nenhum produto encontrado."));
          }

          // 3. Estado: Sucesso (Dados Carregados)
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ListTile(
                leading: Image.network(
                  product.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                ),
                title: Text(product.title),
                subtitle: Text("\$${product.price}"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.viewModel.loadProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}