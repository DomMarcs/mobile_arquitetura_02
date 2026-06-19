import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final viewModel = context.read<ProductViewModel>();

    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Olá, ${auth.user?.fullName ?? 'usuário'}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Pronto para explorar as novidades?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text(
                'Ver Produtos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 4,
                shadowColor: Theme.of(context).colorScheme.primary.withAlpha(100),
              ),
              onPressed: () {
                viewModel.loadProducts();
                Navigator.pushNamed(context, '/products');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}