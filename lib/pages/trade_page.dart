import 'dart:async';

import 'package:flutter/material.dart';
import 'package:autotrade/services/trade_logic.dart'; // Importing your trade logic file
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'assets_page.dart';

class TradePage extends StatefulWidget {
  final Map<String, dynamic> balance;

  const TradePage({super.key, required this.balance});

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  late double totalBalance;
  late double freeBalance;
  late Timer _timer;
  late bool _disposed = false;

  // Method to fetch total balance
  Future<void> fetchTotalBalance() async {
    if (_disposed) return;
    double freeBalanceUSDT = await getFreeBalance();
    double totalBalanceUSD = await getTotalBalance();
    setState(() {
      totalBalance = totalBalanceUSD + freeBalanceUSDT;
      freeBalance = freeBalanceUSDT;
    });
  }

  @override
  void initState() {
    super.initState();
    totalBalance = 0.0;
    freeBalance = 0.0;
    fetchTotalBalance();
    _timer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      fetchTotalBalance();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer.cancel();
    super.dispose();
  }

  TextEditingController entryController = TextEditingController();
  TextEditingController stopLossController = TextEditingController();
  TextEditingController target1Controller = TextEditingController();
  TextEditingController target2Controller = TextEditingController();
  TextEditingController target3Controller = TextEditingController();
  TextEditingController pairController = TextEditingController();
  TextEditingController usdtAmountController = TextEditingController(text: '20');

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                _logout(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFailureDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Failed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Order Failed Try again later'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Success'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Order Successfully placed, check your binance account'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_key');
    await prefs.remove('api_secret');
    Navigator.pushReplacementNamed(context, '/login'); // Assuming '/login' is your login route
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
            title: Padding(
              padding: EdgeInsets.only(left:   paddingSize(20)),
              child: Text(
                'Auto Trade',
                style: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.9)),

              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: fetchTotalBalance,
                iconSize: paddingSize(20),
              ),
              SizedBox(width: paddingSize(10)),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _showLogoutDialog(context),
                iconSize: paddingSize(20),
              ),
              SizedBox(width: paddingSize(20)),

            ],
          ),
          body: Container(
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(paddingSize(20.0)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextFormField(
                          controller: pairController,
                          labelText: 'Trading COIN SYMBOL',
                          fillColor: Colors.blue.withOpacity(0.1)
                      ),
                      SizedBox(height: paddingSize(10)),
                      buildTextFormField(
                          controller: entryController,
                          labelText: 'Entry Price',
                          fillColor: Colors.blue.withOpacity(0.1),
                          keyboardType: TextInputType.number
                      ),
                      SizedBox(height: paddingSize(10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buildTextFormField(
                                controller: target1Controller,
                                labelText: 'Target 1',
                                fillColor: Colors.green.withOpacity(0.1),
                                keyboardType: TextInputType.number
                            ),
                          ),
                          SizedBox(width: paddingSize(10)),
                          Expanded(
                            child: buildTextFormField(
                                controller: target2Controller,
                                labelText: 'Target 2',
                                fillColor: Colors.green.withOpacity(0.1),
                                keyboardType: TextInputType.number
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: paddingSize(10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buildTextFormField(
                                controller: target3Controller,
                                labelText: 'Target 3',
                                fillColor: Colors.green.withOpacity(0.1),
                                keyboardType: TextInputType.number
                            ),
                          ),
                          SizedBox(width: paddingSize(10)),
                          Expanded(
                            child: buildTextFormField(
                                controller: stopLossController,
                                labelText: 'Stop Loss',
                                fillColor: Colors.red.withOpacity(0.1),
                                keyboardType: TextInputType.number
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: paddingSize(10)),
                      buildTextFormField(
                          controller: usdtAmountController,
                          labelText: 'Amount in USDT',
                          fillColor: Colors.blue.withOpacity(0.1),
                          keyboardType: TextInputType.number
                      ),
                      SizedBox(height: paddingSize(20)),
                      ElevatedButton(
                        onPressed: () async {
                          int toStringAsFixed = 5;
                          String result = "";
                          while ((result == "" || result == "LOT_SIZE") &&
                              toStringAsFixed >= 0) {
                            result = await executeTrade(
                              "${pairController.text.toUpperCase()}USDT",
                              'BUY',
                              'LIMIT',
                              'GTC',
                              (double.tryParse(usdtAmountController.text)! /
                                  double.tryParse(entryController.text)!)
                                  .toStringAsFixed(toStringAsFixed),
                              entryController.text,
                            );
                            print(
                                "#\n\n${(double.tryParse(usdtAmountController.text)! / double.tryParse(entryController.text)!).toStringAsFixed(toStringAsFixed)}    $toStringAsFixed");
                            toStringAsFixed -= 1;
                            if (result == "success") {
                              _showSuccessDialog(context);
                            } else if (result == "failure") {
                              _showFailureDialog(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.withOpacity(0.5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(paddingSize(16.0)),
                          child: Text(
                              'Execute Trade',
                            style: TextStyle(fontSize: fontSize(16), color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssetsPage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1), // Background color
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(top: paddingSize(20)),
                      padding: EdgeInsets.symmetric(
                          vertical: paddingSize(20.0), horizontal: paddingSize(40.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance: ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: fontSize(14.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Available for Trading: ',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: fontSize(14.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${totalBalance.toStringAsFixed(2)} USD',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: fontSize(14.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${freeBalance.toStringAsFixed(2)} USDT',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: fontSize(14.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  TextFormField buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required Color fillColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = kIsWeb? screenHeight/2 : MediaQuery.of(context).size.width;

    double fontSize(double size) {
      return size * screenWidth / 375; // Assuming 375 is the base width
    }

    double paddingSize(double size) {
      return size * screenWidth / 375;
    }
    return TextFormField(
      style: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.9)),
      controller: controller,
      decoration: InputDecoration(
        labelStyle: TextStyle(fontSize: fontSize(16), color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic),
        labelText: labelText,
        filled: true,
        fillColor: fillColor,
      ),
      keyboardType: keyboardType,
    );
  }
}
