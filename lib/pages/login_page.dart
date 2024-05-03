import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autotrade/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController apiSecretController = TextEditingController();

  void _login() async {
    final apiKey = apiKeyController.text;
    final apiSecret = apiSecretController.text;

    try {
      final balanceResponse = await fetchBinanceTotalBalance(apiKey, apiSecret);
      if (balanceResponse.containsKey('balances')) {
        final url = Uri.parse('https://api.binance.com/api/v3/ping');
        final headers = {'X-MBX-APIKEY': apiKey};

        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('api_key', apiKey);
          await prefs.setString('api_secret', apiSecret);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: CupertinoColors.systemGreen,
              content: Text('Login successful'),
            ),
          );

          // Redirect to the trade page
          Navigator.pushReplacementNamed(context, '/trade');

          return;
        }
      }

      // If the balance retrieval or ping request fails, show login failure message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Login Failed',textAlign: TextAlign.center,)),
            content: Text('Invalid API key or secret key. Please try again.',textAlign: TextAlign.center,),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Exception occurred
      // Show a popup with "Login Failed" message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Login Failed',textAlign: TextAlign.center,)),
            content: Text('An error occurred: $e',textAlign: TextAlign.center,),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: TextField(
                controller: apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: TextField(
                controller: apiSecretController,
                decoration: InputDecoration(
                  labelText: 'API Secret',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
