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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = HttpClient();
  final sessionManager = SessionManager();
  await sessionManager.initialize();

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
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
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
