import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile_arquitetura_01/core/errors/failure.dart';
import 'package:mobile_arquitetura_01/core/session/session_manager.dart';
import 'package:mobile_arquitetura_01/domain/entities/product.dart';
import 'package:mobile_arquitetura_01/domain/entities/user.dart';
import 'package:mobile_arquitetura_01/domain/repositories/auth_repository.dart';
import 'package:mobile_arquitetura_01/domain/repositories/product_repository.dart';
import 'package:mobile_arquitetura_01/presentation/pages/product_page.dart';
import 'package:mobile_arquitetura_01/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mobile_arquitetura_01/presentation/viewmodels/product_viewmodel.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login(String username, String password) async {
    return User(
      id: 0,
      username: username,
      firstName: 'Teste',
      lastName: 'Usuário',
      token: 'fake-token',
    );
  }
}

Widget _buildWithProviders(ProductRepository productRepository) {
  final session = SessionManager();
  session.saveSession(User(
    id: 0,
    username: 'test',
    firstName: 'Test',
    lastName: 'User',
    token: 'fake-token',
  ));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(
        value: AuthViewModel(
          repository: _FakeAuthRepository(),
          session: session,
        ),
      ),
      ChangeNotifierProvider<ProductViewModel>.value(
        value: ProductViewModel(productRepository),
      ),
    ],
    child: const MaterialApp(home: ProductPage()),
  );
}

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.products);

  final List<Product> products;
  final Set<int> _favorites = {};

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    return products
        .map(
          (p) => Product(
            id: p.id,
            title: p.title,
            price: p.price,
            image: p.image,
            description: p.description,
            category: p.category,
            favorite: _favorites.contains(p.id) || p.favorite,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveFavorites(Set<int> favoriteIds) async {
    _favorites.clear();
    _favorites.addAll(favoriteIds);
  }

  @override
  Future<Set<int>> getFavorites() async {
    return _favorites;
  }
}

class _FailingProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    throw Failure('Falha ao carregar os produtos');
  }

  @override
  Future<void> saveFavorites(Set<int> favoriteIds) async {}

  @override
  Future<Set<int>> getFavorites() async => {};
}

void main() {
  group('Favoritos - Provider', () {
    testWidgets('toggleFavorite alterna icone e atualiza contador', (tester) async {
      final repo = _FakeProductRepository(
        [
          Product(
            id: 1,
            title: 'Notebook',
            price: 3500,
            image: 'https://example.com/notebook.png',
            description: 'Notebook de teste',
            category: 'Eletrônicos',
            favorite: false,
          ),
          Product(
            id: 2,
            title: 'Mouse',
            price: 120,
            image: 'https://example.com/mouse.png',
            description: 'Mouse de teste',
            category: 'Periféricos',
            favorite: false,
          ),
        ],
      );

      await tester.pumpWidget(_buildWithProviders(repo));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Produtos (0 favoritos)'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.favorite_border).first);
      await tester.pump();

      expect(find.text('Produtos (1 favoritos)'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNWidgets(1));
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(1));
    });

    testWidgets('filtro "Somente favoritos" mostra apenas favoritos', (tester) async {
      final repo = _FakeProductRepository(
        [
          Product(
            id: 1,
            title: 'Notebook',
            price: 3500,
            image: 'https://example.com/notebook.png',
            description: 'Notebook de teste',
            category: 'Eletrônicos',
            favorite: false,
          ),
          Product(
            id: 2,
            title: 'Mouse',
            price: 120,
            image: 'https://example.com/mouse.png',
            description: 'Mouse de teste',
            category: 'Periféricos',
            favorite: false,
          ),
        ],
      );

      await tester.pumpWidget(_buildWithProviders(repo));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.favorite_border).first);
      await tester.pump();

      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      expect(find.text('Notebook'), findsOneWidget);
      expect(find.text('Mouse'), findsNothing);
    });

    testWidgets('exibe mensagem de erro quando falha ao carregar', (tester) async {
      final repo = _FailingProductRepository();

      await tester.pumpWidget(_buildWithProviders(repo));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Falha ao carregar os produtos'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
}
