import 'package:binance_ticker/binance_ticker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ExampleTicker());
  }
}

class ExampleTicker extends StatefulWidget {
  const ExampleTicker({super.key});

  @override
  State<ExampleTicker> createState() => _ExampleTickerState();
}

class _ExampleTickerState extends State<ExampleTicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            BinanceTicketWidget(
              pairList: const ['btcusdt', 'ethusdt'],
              pair: 'ethusdt',
            )
          ],
        ));
  }
}
