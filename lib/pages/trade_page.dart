import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autotrade/services/trade_logic.dart'; // Importing your trade logic file
import 'package:shared_preferences/shared_preferences.dart';

import 'assets_page.dart';

class TradePage extends StatefulWidget {
  final Map<String, dynamic> balance;

  TradePage({required this.balance});

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
    double freeBalanceUSDT =
        await getFreeBalance();
    double totalBalanceUSD =
        await getTotalBalance();
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
  TextEditingController usdtAmountController =
      TextEditingController(text: '20');

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
    Navigator.pushReplacementNamed(
        context, '/login'); // Assuming '/login' is your login route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Auto Trade'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchTotalBalance,
            ),
            SizedBox(width: 10,),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: pairController,
                      decoration: InputDecoration(
                        labelText: 'Trading COIN SYMBOL',
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: entryController,
                      decoration: InputDecoration(
                        labelText: 'Entry Price',
                        filled: true,
                        fillColor: Colors.blue.withOpacity(0.08),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: target1Controller,
                            decoration: InputDecoration(
                              labelText: 'Target 1',
                              filled: true,
                              fillColor: Colors.green.withOpacity(0.08),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: target2Controller,
                            decoration: InputDecoration(
                              labelText: 'Target 2',
                              filled: true,
                              fillColor: Colors.green.withOpacity(0.08),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: target3Controller,
                            decoration: InputDecoration(
                              labelText: 'Target 3',
                              filled: true,
                              fillColor: Colors.green.withOpacity(0.08),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: stopLossController,
                            decoration: InputDecoration(
                              labelText: 'Stop Loss',
                              filled: true,
                              fillColor: Colors.red.withOpacity(0.08),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: usdtAmountController,
                      decoration: InputDecoration(
                        labelText: 'Amount in USDT',
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.08),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
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
                              "#\n\n${(double.tryParse(usdtAmountController.text)! / double.tryParse(entryController.text)!).toStringAsFixed(toStringAsFixed)}    ${toStringAsFixed}");
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
                        backgroundColor: Colors.black.withOpacity(0.2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Execute Trade'),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AssetsPage()),
                    );
                  },
                  child: Container(
                    margin:EdgeInsets.only(top:20),
                    color: Colors.grey[200], // Background color
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Balance: ',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Available for Trading: ',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14.0,
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
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${freeBalance.toStringAsFixed(2)} USDT',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14.0,
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
        ));
  }
}
