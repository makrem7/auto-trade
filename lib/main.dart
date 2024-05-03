import 'package:flutter/material.dart';
import 'package:autotrade/pages/login_page.dart';
import 'package:autotrade/pages/trade_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Binance Trade App',
      theme: ThemeData(
        // Your theme data
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthenticationWrapper(),
        '/login': (context) => LoginPage(),
        '/trade': (context) => TradePage(balance: {},),
      },
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Or some loading indicator
        } else {
          if (snapshot.data == true) {
            return TradePage(balance: const {},); // Navigate to trade page if logged in
          } else {
            return LoginPage(); // Navigate to login page if not logged in
          }
        }
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('api_key');
    final apiSecret = prefs.getString('api_secret');
    return apiKey != null && apiSecret != null;
  }
}
