import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceTicketWidget extends StatefulWidget {
  late String pair;
  final String? image;
  final List<String>? imageList;
  final Decoration? decoration;
  final TextStyle? priceStyle;
  final List<String> pairList;

  BinanceTicketWidget(
      {super.key,
      required this.pair,
      this.image,
      this.decoration,
      this.priceStyle,
      required this.pairList,
      this.imageList});

  @override
  State<BinanceTicketWidget> createState() => _BinanceTicketWidgetState();
}

class _BinanceTicketWidgetState extends State<BinanceTicketWidget> {
  kwidth(double val) {
    return MediaQuery.of(context).size.width * val;
  }

  kheight(double val) {
    return MediaQuery.of(context).size.height * val;
  }

  WebSocketChannel? socket;
  Stream? binancestream;

  openbinanceSocket(String pair) {
    if (socket != null) socket!.sink.close();
    var params =
        '{ "method": "SUBSCRIBE", "params": ["$pair@ticker"], "id": 1 }';
    print("Params==>" + params.toString());

    socket =
        WebSocketChannel.connect(Uri.parse('wss://stream.binance.com:9443/ws'));
    socket!.sink.add(params);

    binancestream = socket!.stream.asBroadcastStream();
  }

  @override
  void initState() {
    openbinanceSocket(widget.pair.toLowerCase());

    super.initState();
  }

  List<String> pairList = ['BTCUSDT', 'ETHUSDT'];
  String pair = 'BTCUSDT';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          widget.decoration ?? BoxDecoration(color: Colors.grey.shade200),
      padding: EdgeInsets.all(kwidth(0.05)),
      child: Column(
        children: [
          StreamBuilder(
              stream: binancestream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print("Snapshot data==>" + snapshot.data.toString());
                  var data = jsonDecode(snapshot.data as String)
                      as Map<String, dynamic>;

                  if (data.isNotEmpty && data.containsKey('s')) {
                    // String demopair = data["s"].substring(0, data["s"].length);

                    double priceChange = double.parse(data['P']);
                    String price = data['c'];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                widget.image != null
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            widget.image.toString()),
                                      )
                                    : const CircleAvatar(),
                                SizedBox(
                                  width: kwidth(0.05),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      price,
                                      style: widget.priceStyle ??
                                          TextStyle(
                                              fontSize: kwidth(0.04),
                                              fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: kheight(0.015),
                                    ),
                                    Text(
                                      widget.pair,
                                      style: TextStyle(fontSize: kwidth(0.04)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  priceChange.toString(),
                                  style: TextStyle(
                                      fontSize: kwidth(0.04),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: kheight(0.015),
                                ),
                                Text(
                                  '24 hr Change',
                                  style: TextStyle(fontSize: kwidth(0.03)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }

                return SizedBox(
                    height: kheight(0.2),
                    child: const Center(child: CircularProgressIndicator()));
              }),
          SizedBox(
            height: kheight(0.01),
          ),
          DropdownButton(
            value: widget.pair,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: widget.pairList.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                widget.pair = newValue.toString();
              });
              openbinanceSocket(widget.pair.toLowerCase());
            },
          ),
        ],
      ),
    );
  }
}
