import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autotrade/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
            title: const Center(child: Text('Login Failed', textAlign: TextAlign.center)),
            content: const Text('Invalid API key or secret key. Please try again.', textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
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
            title: const Center(child: Text('Login Failed', textAlign: TextAlign.center)),
            content: Text('An error occurred: $e', textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = kIsWeb? screenHeight/2 : MediaQuery.of(context).size.width;

    double fontSize(double size) {
      return size * screenWidth / 375; // Assuming 375 is the base width
    }

    double paddingSize(double size) {
      return size * screenWidth / 375;
    }

    return Center(
      child: SizedBox(
        width:screenWidth,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.withOpacity(0.1),
            title: Center(
              child: GradientText(
                'AutoTrade',
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                style: TextStyle(
                  fontSize: fontSize(30),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(paddingSize(20.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: paddingSize(50.0), top: paddingSize(50.0)),
                    child: Center(
                      child: GradientText(
                        'Login with your\nAPI Key & API Secret\nAnd trade faster and easier',
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        style: TextStyle(
                          fontSize: fontSize(22),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // SizedBox(height: paddingSize(180)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: paddingSize(30)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    child: TextField(
                      style: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.9),fontStyle: FontStyle.italic),
                      controller: apiKeyController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic),
                        labelText: 'API Key',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: paddingSize(40)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: paddingSize(30)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    child: TextField(
                      style: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.9),fontStyle: FontStyle.italic),
                      controller: apiSecretController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic),
                        labelText: 'API Secret',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: paddingSize(40)),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(horizontal: paddingSize(40), vertical: paddingSize(15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '       Login       ',
                      style: TextStyle(fontSize: fontSize(18), color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: paddingSize(40)),
                ],
              ),

            ),
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Gradient gradient;

  const GradientText(
      this.text, {super.key, 
        required this.gradient,
        this.style = const TextStyle(),
        this.textAlign = TextAlign.center,
      });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white, fontStyle: FontStyle.normal),
      ),
    );
  }
}
