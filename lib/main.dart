import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(home: TradingScreen(), theme: ThemeData.dark(), debugShowCheckedModeBanner: false));

class TradingScreen extends StatefulWidget {
  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String idx = "BANK NIFTY";
  Map<String,String> map = {"NIFTY 50":"^NSEI","BANK NIFTY":"^NSEBANK","SENSEX":"^BSESN"};
  double p=0,h=0,l=0;
  String msg="Loading...";
  bool load=true;

  @override
  void initState(){super.initState(); getData();}

  getData() async {
    setState((){load=true; msg="Fetching...";});
    try{
      String sym=map[idx]!;
      var url=Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$sym?range=5d&interval=1d');
      var r=await http.get(url, headers:{'User-Agent':'Mozilla/5.0'});
      if(r.statusCode==200){
        var d=jsonDecode(r.body);
        var res=d['chart']['result'][0];
        var meta=res['meta'];
        var q=res['indicators']['quote'][0];
        var closes=q['close'] as List;
        var highs=q['high'] as List;
        var lows=q['low'] as List;
        double c=0,h1=0,l1=0;
        for(int i=closes.length-1;i>=0;i--){ if(closes[i]!=null){c=(closes[i] as num).toDouble(); break;}}
        for(int i=highs.length-1;i>=0;i--){ if(highs[i]!=null){h1=(highs[i] as num).toDouble(); break;}}
        for(int i=lows.length-1;i>=0;i--){ if(lows[i]!=null){l1=(lows[i] as num).toDouble(); break;}}
        if(c==0) c=(meta['regularMarketPrice'] as num).toDouble();
        setState((){p=c; h=h1==0?c:h1; l=l1==0?c:l1; msg="LIVE";});
      } else { setState(()=>msg="Error ${r.statusCode}"); }
    }catch(e){ setState(()=>msg="Error $e"); }
    setState(()=>load=false);
  }

  @override
  Widget build(BuildContext context){
    double pp=(h+l+p)/3;
    double r1=2*pp-l; double s1=2*pp-h;
    double r2=pp+(h-l); double s2=pp-(h-l);
    double r3=h+2*(pp-l); double s3=l-2*(h-pp);
    return Scaffold(
      appBar: AppBar(title: Text("Trading Eye - $idx")),
      body: load?Center(child:CircularProgressIndicator()):Padding(
        padding:EdgeInsets.all(16),
        child:Column(children:[
          DropdownButton(value:idx, isExpanded:true, items:map.keys.map((e)=>DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged:(v){setState(()=>idx=v!); getData();}),
          SizedBox(height:10), Text(msg, style:TextStyle(color:Colors.green)),
          SizedBox(height:10), Text("${p.toStringAsFixed(2)}", style:TextStyle(fontSize:42, fontWeight:FontWeight.bold, color:Colors.cyanAccent)),
          Text("H:${h.toStringAsFixed(2)}  L:${l.toStringAsFixed(2)}"),
          SizedBox(height:20),
          _box("R3",r3,Colors.red.shade900), _box("R2",r2,Colors.red.shade400), _box("R1",r1,Colors.red.shade200),
          _box("PP",pp,Colors.yellow, true),
          _box("S1",s1,Colors.green.shade200), _box("S2",s2,Colors.green.shade400), _box("S3",s3,Colors.green.shade900),
          SizedBox(height:20),
          ElevatedButton(onPressed:getData, child:Text("Refresh"), style:ElevatedButton.styleFrom(minimumSize:Size(double.infinity,50))),
        ]),
      ),
    );
  }
  Widget _box(String n,double v,Color c,[bool isPP=false]){
    return Container(margin:EdgeInsets.symmetric(vertical:4), padding:EdgeInsets.all(12), decoration:BoxDecoration(color:c.withOpacity(0.2), border:Border.all(color:c), borderRadius:BorderRadius.circular(8)), child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Text(n, style:TextStyle(color:c, fontWeight:FontWeight.bold, fontSize:isPP?18:14)), Text(v.toStringAsFixed(2), style:TextStyle(fontWeight:FontWeight.bold, fontSize:isPP?18:14))]));
  }
}
