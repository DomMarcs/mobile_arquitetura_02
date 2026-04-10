import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';
import 'services/product_service.dart';

void main() {
  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Produtos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductListScreen(service: ProductService()),
    );
  }
}
