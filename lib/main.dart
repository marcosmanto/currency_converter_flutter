import 'dart:convert';

import 'package:currency_converter_flutter/keys/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  try {
    //Uri.https('api.hgbrasil.com', 'finance', {'format': 'json', 'key': ''})
    http.Response response = await http.get(
        Uri.parse(HgBrasilApi.baseUri.value),
        headers: {'format': 'json', 'key': HgBrasilApi.key.value});
    print(json.decode(response.body)['results']['currencies']['USD']);
  } catch (e) {
    print('Exception: ${e.toString()}');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Hello',
            style: TextStyle(
              color: Colors.red,
              fontSize: 42,
            ),
          ),
        ),
      ),
    );
  }
}
