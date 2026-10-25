import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(TradingEyeApp());

class TradingEyeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading Eye Pro',
      theme: ThemeData.dark(),
      home: TradingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TradingScreen extends StatefulWidget {
  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String selectedIndex = "BANK NIFTY";
  Map<String, String> symbols = {
    "NIFTY 50": "%5ENSEI",
    "SENSEX": "%5EBSESN",
    "BANK NIFTY": "%5ENSEBANK",
  };
  double price = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPrice();
  }

  fetchPrice() async {
    setState(()=> loading = true);
    try {
      String sym = symbols[selectedIndex]!;
      var url = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$sym?interval=1d&range=1d');
      var res = await http.get(url);
      if(res.statusCode==200){
        var data = jsonDecode(res.body);
        var p = data['chart']['result'][0]['meta']['regularMarketPrice'];
        setState(()=> price = p.toDouble());
      }
    } catch(e){}
    setState(()=> loading = false);
  }

  @override
  Widget build(BuildContext context){
    double pp = price;
    double s1 = pp - (pp*0.005);
    double r1 = pp + (pp*0.005);
    return Scaffold(
      appBar: AppBar(title: Text("Trading Eye - $selectedIndex")),
      body: Center(
        child: loading ? CircularProgressIndicator() : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedIndex,
              items: symbols.keys.map((e)=> DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v){ setState(()=> selectedIndex=v!); fetchPrice(); }
            ),
            SizedBox(height: 20),
            Text("${price.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("PP: ${pp.toStringAsFixed(2)}\nS1: ${s1.toStringAsFixed(2)}\nR1: ${r1.toStringAsFixed(2)}", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: fetchPrice, child: Text("Refresh")),
          ],
        )
      ),
    );
  }
}
