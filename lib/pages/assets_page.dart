import 'package:flutter/material.dart';
import 'package:autotrade/services/trade_logic.dart';

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    double fontSize(double size) {
      return size * screenWidth / 375; // Assuming 375 is the base width
    }

    double paddingSize(double size) {
      return size * screenWidth / 375;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.1),
        title: Center(child: Text('Assets',style: TextStyle(
            fontSize: fontSize(22),
            color: Colors.black),)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAssets,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
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
                    columnSpacing: paddingSize(15),
                    columns: const [
                      DataColumn(label: Text('Coin')),
                      DataColumn(label: Text('Balance')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Value \$')),
                    ],
                    rows: filteredAssets.map((asset) {
                      print(asset.key);
                      final symbol = asset.key != 'USDT'
                          ? prices[asset.key]! > 0.001
                              ? asset.key
                              : "1000${asset.key}"
                          : asset.key;
                      final balance =
                          double.tryParse(originalAssets[asset.key]!.toStringAsFixed(4)).toString() ?? '';
                      final price = asset.key == 'USDT'
                          ? '1.0'
                          : double.tryParse(((prices[asset.key]! > 0.001
                                      ? prices[asset.key]
                                      : prices[asset.key]! * 1000) ??
                                  0.0)
                              .toStringAsFixed(4)).toString();
                      final value = asset.value.toStringAsFixed(2);

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              symbol,
                              style: TextStyle(
                                  fontSize: fontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              balance,
                              style: TextStyle(
                                  fontSize: fontSize(16),
                                  color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              price,
                              style: TextStyle(
                                  fontSize: fontSize(16),
                                  color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                  fontSize: fontSize(16),
                                  color: Colors.green),
                              overflow: TextOverflow.clip,
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
    );
  }
}
