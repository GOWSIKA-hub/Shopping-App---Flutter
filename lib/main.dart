import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home.dart';
import 'add_products.dart';
import 'details.dart';
import 'payment.dart';
import 'cartpage.dart';
import 'search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmhxQLYdcU63gI5qkUIKIlfRnAXjIy5aA",
      authDomain: "demoproject-62bad.firebaseapp.com",
      projectId: "demoproject-62bad",
      storageBucket: "demoproject-62bad.firebasestorage.app",
      messagingSenderId: "723873573943",
      appId: "1:723873573943:web:89287b12d3fa993c61e3b2",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/add_products': (context) => const AddProductsPage(),
        '/details': (context) {
          final product = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailsPage(product: product);
        },
        '/payment': (context) => const PaymentPage(),
        '/search': (context) => const SearchPage(),
        '/cart': (context) => const CartPage(),
      },
    );
  }
}