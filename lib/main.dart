import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/pages/home_page.dart';

void main() {
  final httpClient = HttpClient();
  final remoteDatasource = ProductRemoteDatasource(httpClient);
  final cacheDatasource = ProductCacheDatasource();
  
  final repository = ProductRepositoryImpl(remoteDatasource, cacheDatasource);
  final viewModel = ProductViewModel(repository);

  runApp(
    ChangeNotifierProvider.value(
      value: viewModel,
      child: const ProductApp(),
    ),
  );
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arquitetura Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
