import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:autotrade/services/trade_logic.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  Map<String, double> assets = {};
  Map<String, double> originalAssets = {};
  Map<String, double> prices = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    setState(() {
      isLoading = true;
    });

    try {

      Map<String, double> fetchedBalances = await fetchBalances();
      prices = await fetchAssetPricesInUSDT();

      Map<String, double> fetchedAssets = {};

      fetchedBalances.forEach((symbol, balance) {
        double price = symbol == 'USDT' ? 1.0 : (prices[symbol] ?? 0.0);
        fetchedAssets[symbol] = balance * price;
      });

      setState(() {
        originalAssets = fetchedBalances;
        assets = Map.fromEntries(
          fetchedAssets.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets =
        assets.entries.where((entry) => entry.value > 0).toList();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth =
    kIsWeb ? screenHeight / 2 : MediaQuery.of(context).size.width;

    double fontSize(double size) {
      return size * screenWidth / 375; // Assuming 375 is the base width
    }

    double paddingSize(double size) {
      return size * screenWidth / 375;
    }

    return Center(
      child: SizedBox(
        width: screenWidth,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: paddingSize(50),
            leading: IconButton(
              icon:  Icon(Icons.arrow_back, size: fontSize(22),),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.grey.withOpacity(0.1),
            title: Center(
                child: Text(
                  'Assets',
                  style: TextStyle(fontSize: fontSize(22), color: Colors.black),
                )),
            actions: [
              IconButton(
                icon:  Icon(Icons.refresh, size: fontSize(22),),
                onPressed: fetchAssets,
              ),
            ],
          ),
          body: isLoading
              ?  const Center(
            child: CircularProgressIndicator(),
          )
              : Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.1),
                  Colors.blue.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.left,
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowHeight: fontSize(40),
                    columnSpacing: paddingSize(15),
                    columns:  [
                      DataColumn(label: Text('',style: TextStyle(
                          fontSize: fontSize(16),
                          color: Colors.black),)),
                      DataColumn(label: Text('Coin',style: TextStyle(
                          fontSize: fontSize(16),
                          color: Colors.black),)),
                      DataColumn(label: Text('Price',style: TextStyle(
                          fontSize: fontSize(16),
                          color: Colors.black),)),
                      DataColumn(label: Text('Balance',style: TextStyle(
                          fontSize: fontSize(16),
                          color: Colors.black),)),
                    ],
                    rows: filteredAssets.map((asset) {
                      final symbol = asset.key != 'USDT'
                          ? prices[asset.key]! > 0.001
                          ? asset.key
                          : "1000${asset.key}"
                          : asset.key;
                      final balance =
                      double.tryParse(originalAssets[asset.key]!
                          .toStringAsFixed(4))
                          .toString();
                      final price = asset.key == 'USDT'
                          ? '1.0'
                          : double.tryParse(((prices[asset.key]! > 0.001
                          ? prices[asset.key]
                          : prices[asset.key]! * 1000) ??
                          0.0)
                          .toStringAsFixed(4))
                          .toString();
                      final logoUrl =
                          // 'https://raw.githubusercontent.com/makrem7/coin-logos-scraping/refs/heads/main/logos/${asset.key.toUpperCase()}.png'; // Replace with the actual logo service
                          'https://bin.bnbstatic.com/static/assets/logos/${asset.key.toUpperCase()}.png'; // Replace with the actual logo service
                      // "https://cryptologos.cc/logos/thumbs/${asset.key.toLowerCase()}.png";
                      // coinImages[asset.key.toLowerCase()];

                      return DataRow(
                        cells: [
                          DataCell(
                            Image.network(
                              logoUrl??"https://raw.githubusercontent.com/makrem7/coin-logos-scraping/refs/heads/main/logos/${asset.key.toLowerCase()}.png",
                              width: fontSize(28),
                              height: fontSize(28),
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.circle_outlined, size: fontSize(28)),
                            ),
                          ),
                          DataCell(
                            Text(
                              symbol,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize(15),
                                  color: Colors.black),
                            ),
                          ),
                          DataCell(
                            Text(
                              price,
                              style: TextStyle(
                                  fontSize: fontSize(16),
                                  color: Colors.black),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\$${asset.value.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontSize(14),
                                      color: Colors.green),
                                ),
                                Text(
                                  balance,
                                  style: TextStyle(
                                      fontSize: fontSize(12),
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
