import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> fetchBinanceTotalBalance(String apiKey, String secretKey) async {
  // Construct the timestamp for the request
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  // Construct the query parameters
  Map<String, String> queryParams = {
    'timestamp': timestamp.toString(),
  };

  // Sort the query parameters
  List<String> keys = queryParams.keys.toList()..sort();
  String queryString = keys.map((key) => '$key=${queryParams[key]}').join('&');

  // Construct the signature
  String signature = _hmacSha256(queryString, secretKey);

  // Construct the request URL
  String url = 'https://api.binance.com/api/v3/account?$queryString&signature=$signature';

  // Make the request
  http.Response response = await http.get(Uri.parse(url), headers: {
    'X-MBX-APIKEY': apiKey,
  });

  // Parse the response
  return json.decode(response.body);
}

String _hmacSha256(String message, String key) {
  var bytes = utf8.encode(key);
  var hmacSha256 = Hmac(sha256, bytes);
  var digest = hmacSha256.convert(utf8.encode(message));
  return digest.toString();
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('api_key');
  await prefs.remove('api_secret');
  Navigator.pushReplacementNamed(
      context, '/login'); // Assuming '/login' is your login route
}