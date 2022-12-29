import 'dart:convert';
import 'dart:ffi';

import 'package:currency_converter_flutter/keys/api_keys.dart';
import 'package:currency_converter_flutter/utils/clear_focus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  //print(await getData());
  runApp(MyApp());
}

class ResponseServerError implements Exception {
  String errMsg() => 'A server error was returned.';
}

Future<Map>? getData() async {
  final http.Response response;
  try {
    response = await http.get(
        Uri.parse('${HgBrasilApi.baseUri.value}?key=${HgBrasilApi.key.value}'));
  } catch (e) {
    print('Exception: ${e.toString()}');
    throw ResponseServerError();
  }
  print(response.body);
  if (response.statusCode >= 400) throw ResponseServerError();
  //await Future.delayed(Duration(seconds: 5));
  return json.decode(response.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Colors.amber),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
          labelStyle: TextStyle(fontSize: 20),
        ),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.amber[600],
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.black,
            ),
            SizedBox(width: 4),
            Text(
              message,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void _realChanged(String text) {
    text = text.replaceAll(',', '.');
    final double? real = double.tryParse(text);
    if (real != null) {
      dolarController.text = (real / dolar!).toStringAsFixed(2);
      euroController.text = (real / euro!).toStringAsFixed(2);
    } else {
      _showValidationError('Digite um número válido para o real.');
      dolarController.clear();
      euroController.clear();
    }
  }

  void _dolarChanged(String text) {
    text = text.replaceAll(',', '.');
    final double? dolar = double.tryParse(text);
    if (dolar != null) {
      realController.text = (dolar * this.dolar!).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
    } else {
      _showValidationError('Digite um número válido para o dolar.');
      realController.clear();
      euroController.clear();
    }
  }

  void _euroChanged(String text) {
    text = text.replaceAll(',', '.');
    final double? euro = double.tryParse(text);
    if (euro != null) {
      realController.text = (euro * this.euro!).toStringAsFixed(2);
      dolarController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
    } else {
      _showValidationError('Digite um número válido para o euro.');
      realController.clear();
      dolarController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClearFocus(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '💵 Conversor 💵',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                      SizedBox(height: 10),
                      Text('Carregando...',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                          ))
                    ],
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar os dados.',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 14,
                      ),
                    ),
                  );
                } else {
                  dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                  euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          ...buildTextField('Reais', 'R',
                              controller: realController,
                              onChanged: _realChanged,
                              divider: true),
                          ...buildTextField('Dólares', 'US',
                              controller: dolarController,
                              onChanged: _dolarChanged,
                              divider: true),
                          ...buildTextField('Euros', '€',
                              controller: euroController,
                              onChanged: _euroChanged,
                              divider: false),
                        ]),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}

List<Widget> buildTextField(String label, String prefix,
    {bool divider = false,
    required TextEditingController controller,
    required void Function(String)? onChanged}) {
  return [
    TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$prefix\$ ',
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    if (divider) Divider(),
  ];
}
