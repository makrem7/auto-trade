import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch current prices of assets in USDT
Future<Map<String, double>> fetchAssetPricesInUSDT() async {
  final url = Uri.parse('https://api.binance.com/api/v3/ticker/price');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> pricesData = jsonDecode(response.body);
      final Map<String, double> prices = {};

      for (var data in pricesData) {
        final String symbol = data['symbol'];
        final double price = double.parse(data['price']);
        if (symbol.endsWith('USDT')) {
          prices[symbol.replaceFirst('USDT', '')] = price; // Remove 'USDT' from symbol
        }
      }
      return prices;
    } else {
      print('Failed to fetch asset prices. Status code: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Exception occurred while fetching asset prices: $e');
    return {};
  }
}

// Function to fetch balances from the Binance API
Future<Map<String, double>> fetchBalances() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? apiKey = prefs.getString('api_key');
  final String? apiSecret = prefs.getString('api_secret');

  if (apiKey == null || apiSecret == null) {
    print('API Key or API Secret not found in SharedPreferences');
    return {};
  }

  final ts = DateTime.now().millisecondsSinceEpoch;
  final param = 'timestamp=$ts';
  final hmac = Hmac(sha256, utf8.encode(apiSecret));
  final hash = hmac.convert(utf8.encode(param)).toString();

  final url = Uri.parse('https://api.binance.com/api/v3/account?timestamp=$ts&signature=$hash');
  final headers = {
    'X-MBX-APIKEY': apiKey,
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Parse the response and extract balances
      Map<String, double> balances = {};
      for (var asset in responseData['balances']) {
        final String symbol = asset['asset'];
        final double free = double.parse(asset['free']);
        final double locked = double.parse(asset['locked']);
        final double totalBalance = free + locked;
        balances[symbol] = totalBalance;
      }

      return balances;
    } else {
      print('Failed to fetch balances. Status code: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Exception occurred while fetching balances: $e');
    return {};
  }
}

Future<List<Map<String, dynamic>>> getAssets() async {
  // Fetch balance data from Binance API or any other source
  // Example implementation:
  final Map<String, dynamic> balances = await fetchBalances(); // Assuming this function exists in trade_logic.dart

  // Filter assets with balance greater than 0
  List<Map<String, dynamic>> assets = [];
  balances.forEach((asset, balance) {
    if (balance > 0) {
      assets.add({'asset': asset, 'balance': balance});
    }
  });
  return assets;
}

Future<String> executeTrade(String pair, String side, String type, String timeInForce, String quantity, String price) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? apiKey = prefs.getString('api_key');
  final String? apiSecret = prefs.getString('api_secret');

  if (apiKey == null || apiSecret == null) {
    return "failure";
  }

  final ts = DateTime.now().millisecondsSinceEpoch;
  final param = 'symbol=$pair&side=$side&type=$type&timeInForce=$timeInForce&quantity=$quantity&price=$price&recvWindow=5000&timestamp=$ts';
  final hmac = Hmac(sha256, utf8.encode(apiSecret));
  final hash = hmac.convert(utf8.encode(param)).toString();

  final url = Uri.parse('https://api.binance.com/api/v3/order');
  final headers = {
    'X-MBX-APIKEY': apiKey,
  };
  final body = {
    "symbol": pair,
    "side": side,
    "type": type,
    "timeInForce": timeInForce,
    "quantity": quantity.toString(),
    "price": price.toString(),
    "recvWindow":"5000",
    'timestamp': ts.toString(),
    "signature":hash.toString(),
  };

  try {
    final response = await http.post(url, headers: headers, body: body);
    final responseBody = response.body;
    print(responseBody);

// Parse the response body as JSON
    final Map<String, dynamic> jsonResponse = json.decode(responseBody);
    print(jsonResponse["msg"]);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return "success";
    }
    else if (jsonResponse["msg"] == "Filter failure: LOT_SIZE") {
      return "LOT_SIZE";
    }
    else {
      return "failure";
    }
  } catch (e) {
    return "failure";
  }
}

Future<double> getFreeBalance() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? apiKey = prefs.getString('api_key');
  final String? apiSecret = prefs.getString('api_secret');

  if (apiKey == null || apiSecret == null) {
    print('API Key or API Secret not found in SharedPreferences');
    return 0.0;
  }

  final ts = DateTime.now().millisecondsSinceEpoch;
  final param = 'timestamp=$ts';
  final hmac = Hmac(sha256, utf8.encode(apiSecret));
  final hash = hmac.convert(utf8.encode(param)).toString();

  final url = Uri.parse('https://api.binance.com/api/v3/account?timestamp=$ts&signature=$hash');
  final headers = {
    'X-MBX-APIKEY': apiKey,
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Calculate total balance from responseData
      double totalBalance = 0.0;
      for (var asset in responseData['balances']) {
        if (asset["asset"]=="USDT")
          {
            totalBalance += double.parse(asset['free']);
            totalBalance += double.parse(asset['locked']);
          }
      }
      return totalBalance;
    } else {
      print('Failed to fetch balance. Status code: ${response.statusCode}');
      return 0.0;
    }
  } catch (e) {
    print('Exception occurred while fetching balance: $e');
    return 0.0;
  }
}
Future<double> getTotalBalance() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? apiKey = prefs.getString('api_key');
  final String? apiSecret = prefs.getString('api_secret');

  if (apiKey == null || apiSecret == null) {
    print('API Key or API Secret not found in SharedPreferences');
    return 0.0;
  }

  final ts = DateTime.now().millisecondsSinceEpoch;
  final param = 'timestamp=$ts';
  final hmac = Hmac(sha256, utf8.encode(apiSecret));
  final hash = hmac.convert(utf8.encode(param)).toString();

  final url = Uri.parse('https://api.binance.com/api/v3/account?timestamp=$ts&signature=$hash');
  final headers = {
    'X-MBX-APIKEY': apiKey,
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Fetch current prices of assets in USD
      final Map<String, double> prices = await fetchAssetPricesInUSD();

      // Calculate total balance in USD
      double totalBalanceUSD = 0.0;
      for (var asset in responseData['balances']) {
        final String symbol = asset['asset'];
        final double free = double.parse(asset['free']);
        final double locked = double.parse(asset['locked']);
        final double balanceInUSD = (free + locked) * (prices["${symbol}USDT"] ?? 0.0);
        totalBalanceUSD += balanceInUSD;
      }
      return totalBalanceUSD;
    } else {
      print('\n\n###\n\n\nFailed to fetch balance. Status code: ${response.statusCode}');
      return 0.0;
    }
  } catch (e) {
    print('\n\n###\n\n\nException occurred while fetching balance: $e');
    return 0.0;
  }
}

Future<Map<String, double>> fetchAssetPricesInUSD() async {
  final response = await http.get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));
  if (response.statusCode == 200) {
    final List<dynamic> pricesData = jsonDecode(response.body);
    final Map<String, double> prices = {};
    for (var data in pricesData) {
      final String symbol = data['symbol'];
      final double priceInUSD = double.parse(data['price']);
      prices[symbol] = priceInUSD;
    }
    return prices;
  } else {
    throw Exception('Failed to fetch asset prices. Status code: ${response.statusCode}');
  }
}