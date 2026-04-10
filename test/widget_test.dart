import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile_arquitetura_02/core/errors/failure.dart';
import 'package:mobile_arquitetura_02/domain/entities/product.dart';
import 'package:mobile_arquitetura_02/domain/repositories/product_repository.dart';
import 'package:mobile_arquitetura_02/presentation/pages/product_page.dart';
import 'package:mobile_arquitetura_02/presentation/viewmodels/product_viewmodel.dart';

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Product>> getProducts() async {
    // Retorna cópias, para o ViewModel mutar `favorite` sem alterar o fixture.
    return products
        .map(
          (p) => Product(
            id: p.id,
            title: p.title,
            price: p.price,
            image: p.image,
            description: p.description,
            category: p.category,
            favorite: p.favorite,
          ),
        )
        .toList();
  }
}

class _FailingProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async {
    throw Failure('Falha ao carregar os produtos');
  }
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
            description: 'Notebook gamer',
            category: 'Eletronicos',
            favorite: false,
          ),
          Product(
            id: 2,
            title: 'Mouse',
            price: 120,
            image: 'https://example.com/mouse.png',
            description: 'Mouse sem fio',
            category: 'Eletronicos',
            favorite: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: ProductViewModel(repo),
          child: const MaterialApp(home: ProductPage()),
        ),
      );

      // Nao esperamos carregamento das imagens da web (rede), apenas a mudanca do estado do ViewModel.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Produtos (0 favoritos)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));

      // Toca no primeiro item (primeiro star_border).
      await tester
          .tap(find.widgetWithIcon(IconButton, Icons.star_border).first);
      await tester.pump();

      expect(find.text('Produtos (1 favoritos)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(1));
      expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    });

    testWidgets('filtro "Somente favoritos" mostra apenas favoritos', (tester) async {
      final repo = _FakeProductRepository(
        [
          Product(
            id: 1,
            title: 'Notebook',
            price: 3500,
            image: 'https://example.com/notebook.png',
            description: 'Notebook gamer',
            category: 'Eletronicos',
            favorite: false,
          ),
          Product(
            id: 2,
            title: 'Mouse',
            price: 120,
            image: 'https://example.com/mouse.png',
            description: 'Mouse sem fio',
            category: 'Eletronicos',
            favorite: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: ProductViewModel(repo),
          child: const MaterialApp(home: ProductPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Marca o primeiro item como favorito.
      await tester
          .tap(find.widgetWithIcon(IconButton, Icons.star_border).first);
      await tester.pump();

      // Ativa o filtro "Somente favoritos" (Switch no AppBar).
      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      expect(find.text('Notebook'), findsOneWidget);
      expect(find.text('Mouse'), findsNothing);
    });

    testWidgets('exibe mensagem de erro quando falha ao carregar', (tester) async {
      final repo = _FailingProductRepository();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: ProductViewModel(repo),
          child: const MaterialApp(home: ProductPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Falha ao carregar os produtos'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
}
