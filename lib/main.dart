import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(CotacaoApp());
}

class CotacaoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using MultiProvider is convenient when providing multiple objects.
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          typography: Typography.material2018()),
      home: const FormularioCotacao(title: 'Cotação de moeda'),
    );
  }
}

class FormularioCotacao extends StatefulWidget {
  const FormularioCotacao({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<FormularioCotacao> createState() => _FormularioCotacaoState();
}

class _FormularioCotacaoState extends State<FormularioCotacao> {
  final fromTextController = TextEditingController();
  List<String> currencies = [];
  String toCurrency = "BRL";
  String fromCurrency = 'USD';
  String result = '';

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<String> _loadCurrencies() async {
    String uri = "https://api.exchangeratesapi.io/latest";
    var response =
        await http.get(Uri.parse(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    Map<String, dynamic> curMap = responseBody['rates'];
    currencies = curMap.keys.toList();
    setState(() {});
    print(currencies);
    return "Success";
  }

  Future<String> _doConversion() async {
    String uri =
        "https://api.exchangeratesapi.io/latest?base=$fromCurrency&symbols=$toCurrency";
    var response =
        await http.get(Uri.parse(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    setState(() {
      result = (double.parse(fromTextController.text) *
              (responseBody["rates"][toCurrency]))
          .toString();
    });
    print(result);
    return "Success";
  }

  _onFromChanged(String value) {
    setState(() {
      fromCurrency = value;
    });
  }

  _onToChanged(String value) {
    setState(() {
      toCurrency = value;
    });
  }

  late String dropdownValue = 'Real';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text('Cotação', style: Theme.of(context).textTheme.bodyText2),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Moeda Local: ",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildDropDownButton(fromCurrency),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Moeda Estrangeira: ",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildDropDownButton(toCurrency)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDownButton(String moedaAtual) {
    return DropdownButton<String>(
      value: moedaAtual,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      items: currencies
          .map((String value) => DropdownMenuItem(
                value: value,
                child: Row(
                  children: <Widget>[
                    Text(value),
                  ],
                ),
              ))
          .toList(),
      onChanged: (String? value) {
        if (moedaAtual == fromCurrency) {
          _onFromChanged(value!);
        } else {
          _onToChanged(value!);
        }
      },
    );
  }
}
