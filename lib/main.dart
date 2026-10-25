<!DOCTYPE html>
<html lang="mr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Trading Eye PRO</title>
<style>
*{box-sizing:border-box} body{margin:0;background:#08111f;color:white;font-family:Arial,sans-serif}
header{background:#111f33;padding:20px;text-align:center;border-bottom:2px solid #00d9a5}
header h1{margin:0;color:#00e6ad} header p{color:#a8b9ce;margin-bottom:0}
.container{padding:15px;max-width:600px;margin:auto}
.card{background:#122139;border:1px solid #263c59;border-radius:12px;padding:16px;margin-bottom:15px}
h2{color:#00e6ad;font-size:18px;margin-top:0}
label{display:block;margin-top:12px;color:#cbd8e8;font-size:14px}
input{width:100%;padding:12px;margin-top:6px;background:#07101d;color:white;border:1px solid #344967;border-radius:7px;font-size:16px}
button{width:100%;padding:14px;margin-top:15px;border:none;border-radius:8px;background:#00d9a5;color:#06131b;font-size:16px;font-weight:bold;cursor:pointer}
.result{background:#07101d;padding:15px;margin-top:12px;border-radius:8px;line-height:1.8}
.green{color:#00efa9;font-weight:bold} .red{color:#ff6377;font-weight:bold} .yellow{color:#ffd166;font-weight:bold}
footer{text-align:center;padding:20px;color:#8295ad;font-size:12px}
</style>
</head>
<body>
<header><h1>👁️ TRADING EYE</h1><p>ORB PRO • NIFTY • CE / PE</p></header>
<div class="container">
    <div class="card">
        <h2>📊 ORB Market Analysis</h2>
        <label>Opening Range High</label><input type="number" id="orbHigh" placeholder="उदा. 23150">
        <label>Opening Range Low</label><input type="number" id="orbLow" placeholder="उदा. 23100">
        <label>सध्याचा NIFTY Spot Price</label><input type="number" id="spot" placeholder="सध्याची किंमत">
        <label>Breakout नंतरची Candle Close Price</label><input type="number" id="closePrice" placeholder="Close">
        <button onclick="analyzeMarket()">ANALYZE MARKET</button>
        <div class="result" id="marketResult">Market data टाका आणि Analyze करा.</div>
    </div>
    <div class="card">
        <h2>💰 Option Premium Planner</h2>
        <label>Option Premium Entry (₹)</label><input type="number" id="premium" placeholder="उदा. 100">
        <label>Stop Loss किती टक्के? (%)</label><input type="number" id="slPercent" value="20">
        <label>Risk : Reward (Target 1)</label><input type="number" id="rr" value="1.5" step="0.5">
        <button onclick="calculatePremium()">CALCULATE ENTRY / SL / TARGET</button>
        <div class="result" id="premiumResult">Premium ची किंमत टाकून गणना करा.</div>
    </div>
    <div class="card"><h2>🛡️ False Breakout Filter</h2><p>फक्त Range च्या बाहेर Price गेली म्हणून लगेच ट्रेड घेऊ नका. पूर्ण झालेल्या Candle चा Close आणि पुढील Price Action तपासा.</p><p class="yellow">ORB हा एकटाच खात्रीशीर Buy/Sell Signal नाही.</p></div>
</div>
<footer>TRADING EYE PRO • Educational Tool<br>Live market data connected नाही.</footer>
<script>
function analyzeMarket(){
    const high=Number(document.getElementById("orbHigh").value);
    const low=Number(document.getElementById("orbLow").value);
    const spot=Number(document.getElementById("spot").value);
    const close=Number(document.getElementById("closePrice").value);
    const result=document.getElementById("marketResult");
    if(!high||!low||!spot||!close||high<=low){result.innerHTML='<span class="yellow">कृपया योग्य Market Prices भरा.</span>';return;}
    if(close>high && spot>high){result.innerHTML='<span class="green">ORB BULLISH BREAKOUT</span><br>संभाव्य Bias: BUY CE<br>Range High: '+high.toFixed(2)+'<br>Spot: '+spot.toFixed(2)+'<br>Candle Close: '+close.toFixed(2)+'<br><span class="yellow">Entry आधी Retest, SL आणि Risk तपासा.</span>';}
    else if(close<low && spot<low){result.innerHTML='<span class="red">ORB BEARISH BREAKDOWN</span><br>संभाव्य Bias: BUY PE<br>Range Low: '+low.toFixed(2)+'<br>Spot: '+spot.toFixed(2)+'<br>Candle Close: '+close.toFixed(2)+'<br><span class="yellow">Entry आधी Retest, SL आणि Risk तपासा.</span>';}
    else{result.innerHTML='<span class="yellow">NO CONFIRMED BREAKOUT</span><br>Price अजूनही Range मध्येच आहे.<br>Spot: '+spot.toFixed(2); }
}
function calculatePremium(){
    const premium=Number(document.getElementById("premium").value);
    const slP=Number(document.getElementById("slPercent").value);
    const rr=Number(document.getElementById("rr").value);
    const res=document.getElementById("premiumResult");
    if(!premium||!slP||!rr){res.innerHTML='<span class="yellow">Premium / SL / RR भरा.</span>';return;}
    const sl=premium*(1-slP/100);
    const target1=premium+(premium-sl)*rr;
    const target2=premium+(premium-sl)*rr*1.5;
    res.innerHTML='Entry: ₹'+premium.toFixed(2)+'<br><span class="red">SL: ₹'+sl.toFixed(2)+' ('+slP+'%)</span><br><span class="green">Target 1 (1:'+rr+'): ₹'+target1.toFixed(2)+'</span><br><span class="green">Target 2: ₹'+target2.toFixed(2)+'</span><br><span class="yellow">Risk: ₹'+(premium-sl).toFixed(2)+' Reward: ₹'+(target1-premium).toFixed(2)+'</span>';
}
</script>
</body>
</html>
