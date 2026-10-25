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
  String selectedIndex = "NIFTY 50";
  Map<String, String> symbols = {
    "NIFTY 50": "%5ENSEI",
    "SENSEX": "%5EBSESN",
    "BANK NIFTY": "%5ENSEBANK",
  };

  double price = 0;
  double high = 0;
  double low = 0;
  double prevClose = 0;
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() { loading = true; error = ""; });
    try {
      String yahooSymbol = symbols[selectedIndex]!;
      // Yahoo Finance API
      var url = Uri.parse("https://query1.finance.yahoo.com/v8/finance/chart/$yahooSymbol?range=5d&interval=1d");
      var res = await http.get(url, headers: {"User-Agent": "Mozilla/5.0"});
      var jsonData = jsonDecode(res.body);
      var result = jsonData['chart']['result'][0];
      var meta = result['meta'];
      var indicators = result['indicators']['quote'][0];
      
      double current = meta['regularMarketPrice']?.toDouble() ?? 0;
      List highs = indicators['high'];
      List lows = indicators['low'];
      List closes = indicators['close'];
      
      double lastHigh = highs.last?.toDouble() ?? current;
      double lastLow = lows.last?.toDouble() ?? current;
      double lastClose = closes[closes.length-2]?.toDouble() ?? current; // prev day close

      setState(() {
        price = current;
        high = lastHigh;
        low = lastLow;
        prevClose = lastClose;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Live data error, check internet";
        loading = false;
      });
    }
  }

  Map<String, double> getSR() {
    if (high == 0) return {};
    double pp = (high + low + prevClose) / 3;
    double r1 = (2 * pp) - low;
    double s1 = (2 * pp) - high;
    double r2 = pp + (high - low);
    double s2 = pp - (high - low);
    double r3 = high + 2 * (pp - low);
    double s3 = low - 2 * (high - pp);
    return {"R3": r3, "R2": r2, "R1": r1, "PP": pp, "S1": s1, "S2": s2, "S3": s3};
  }

  @override
  Widget build(BuildContext context) {
    var sr = getSR();
    return Scaffold(
      appBar: AppBar(
        title: Text("Trading Eye - LIVE $selectedIndex"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchData)
        ],
      ),
      backgroundColor: Color(0xFF0D1117),
      body: loading ? Center(child: CircularProgressIndicator()) :
      SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown for Nifty/Sensex/BankNifty
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(
                value: selectedIndex,
                isExpanded: true,
                dropdownColor: Colors.black,
                underline: SizedBox(),
                items: symbols.keys.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))).toList(),
                onChanged: (v) {
                  setState(() => selectedIndex = v!);
                  fetchData();
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(selectedIndex, style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(price.toStringAsFixed(2), style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("H: ${high.toStringAsFixed(2)}  L: ${low.toStringAsFixed(2)}  Prev: ${prevClose.toStringAsFixed(2)}", style: TextStyle(color: Colors.grey)),
                  if (error.isNotEmpty) Text(error, style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text("Today's Support / Resistance (Pivot)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ...["R3","R2","R1","PP","S1","S2","S3"].map((level) => 
              Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: level.startsWith("R") ? Colors.red.withOpacity(0.15) : level.startsWith("S") ? Colors.green.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: level.startsWith("R") ? Colors.red : level.startsWith("S") ? Colors.green : Colors.blue, width: 1)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(level, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(sr[level]?.toStringAsFixed(2) ?? "-", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ).toList(),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: fetchData, icon: Icon(Icons.refresh), label: Text("Refresh LIVE Data"), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50))),
          ],
        ),
      ),
    );
  }
}
