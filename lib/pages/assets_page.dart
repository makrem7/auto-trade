import 'package:flutter/material.dart';
import 'package:autotrade/services/trade_logic.dart';

class AssetsPage extends StatefulWidget {
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
    final filteredAssets = assets.entries.where((entry) => entry.value > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Assets'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAssets,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
            child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
            columnSpacing: 10,
            columns: [
              DataColumn(label: Text('Coin')),
              DataColumn(label: Text('Balance')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Value \$')),
            ],
            rows: filteredAssets.map((asset) {
              print(asset.key);
              final symbol = asset.key != 'USDT'? prices[asset.key]!>0.001?asset.key:"1000${asset.key}":asset.key;
              final balance = originalAssets[asset.key]?.toStringAsFixed(4) ?? '';
              final price = asset.key == 'USDT' ? '1.0' : ((prices[asset.key]!>0.001?prices[asset.key]:prices[asset.key]!*1000) ?? 0.0).toStringAsFixed(4);
              final value = asset.value.toStringAsFixed(2);
            
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      symbol,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      balance,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      price,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      value,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              );
            }).toList(),
                    ),
                  ),
          ),
    );
  }
}
