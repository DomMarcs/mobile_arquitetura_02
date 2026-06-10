import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final viewModel = context.read<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo à Loja'),
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Olá, ${auth.user?.fullName ?? 'usuário'}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Explore nossos produtos DummyJSON.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                viewModel.loadProducts();
                Navigator.pushNamed(context, '/products');
              },
              child: const Text('Ver Produtos'),
            ),
          ],
        ),
      ),
    );
  }
}