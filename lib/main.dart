import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Currency>> fetchCurrencies(http.Client client) async {
  final response = await client.get(
    Uri.parse('https://api.collectapi.com/economy/currencyToAll?int=1&base=TRY'),
    headers: {
      HttpHeaders.authorizationHeader: 'apikey 0DnloftBYOFUeVGd6ppmcJ:33siTwVCsBfpbdsogkJJ1h',
    },
  );

  return compute(parseCurrencies, response.body);
}

List<Currency> parseCurrencies(String responseBody) {
  final parsed = jsonDecode(responseBody)['result']['data'] as List<dynamic>;

  return parsed.map<Currency>((json) => Currency.fromJson(json)).toList();
}

class Currency {
  final String code;
  final String name;
  final double rate;
  final double calculated;

  Currency({
    required this.code,
    required this.name,
    required this.rate,
    required this.calculated,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      rate: json['rate'].toDouble(),
      calculated: json['calculated'].toDouble(),
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Döviz Uygulaması';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Currency>> _currencyList;
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _currencyList = fetchCurrencies(http.Client());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red,
      ),
      body: Column(
          children: [
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          labelText: 'Para Birimini Arayın!',
          border: OutlineInputBorder(),
        ),
      ),
    ),
    Expanded(
    child: FutureBuilder<List<Currency>>(
    future: _currencyList,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        // Filter currencies based on search text
        List<Currency> filteredCurrencies = snapshot.data!
            .where((currency) =>
        currency.name.toLowerCase().contains(_searchText) ||
            currency.code.toLowerCase().contains(_searchText))
            .toList();

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
          ),
          itemCount: filteredCurrencies.length,
          itemBuilder: (context, index) {
            final currency = filteredCurrencies[index];
            return Card(
              child: ListTile(
                title: Text(currency.name),
                subtitle: Text(currency.code),
                trailing: Text(currency.rate.toString()),
              ),
            );
          },
        );
      } else if (snapshot.hasError) {
        return Text("${snapshot.error}");
      }

      // By default, show a loading spinner
      return Center(child: CircularProgressIndicator());
    },
    ),
    ),
          ],
      ),
    );
  }
}

