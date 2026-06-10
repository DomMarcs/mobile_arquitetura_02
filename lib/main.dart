import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_client.dart';
import 'core/session/session_manager.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/product_page.dart';

void main() {
  final httpClient = HttpClient();
  final sessionManager = SessionManager();

  final authRemoteDatasource = AuthRemoteDatasource(httpClient);
  final authRepository = AuthRepositoryImpl(authRemoteDatasource);
  final authViewModel = AuthViewModel(
    repository: authRepository,
    session: sessionManager,
  );

  final productRemoteDatasource = ProductRemoteDatasource(httpClient);
  final cacheDatasource = ProductCacheDatasource();
  final productRepository = ProductRepositoryImpl(productRemoteDatasource, cacheDatasource);
  final productViewModel = ProductViewModel(productRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ChangeNotifierProvider<ProductViewModel>.value(value: productViewModel),
      ],
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
      initialRoute: '/',
      routes: {
        '/': (context) {
          final auth = context.watch<AuthViewModel>();
          return auth.isAuthenticated ? const HomePage() : const LoginPage();
        },
        '/home': (context) => const HomePage(),
        '/products': (context) => const ProductPage(),
      },
    );
  }
}
