import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const BinomoApp());
}

class BinomoApp extends StatelessWidget {
  const BinomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binomo Prediction Signal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const TradingScreen(),
    );
  }
}

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String selectedAsset = 'BTC/USD';
  String currentSignal = 'Analyzing...';
  double confidence = 0.0;
  int expiryTime = 60; // 1 minute in seconds
  Timer? _timer;
  bool isAnalyzing = true;

  // Mock candle data
  List<CandleData> candleData = [];

  final List<String> assets = [
    'BTC/USD',
    'ETH/USD',
    'AAPL',
    'GOLD',
    'EUR/USD',
    'OIL',
  ];

  @override
  void initState() {
    super.initState();
    _generateMockData();
    _startAnalysis();
  }

  void _generateMockData() {
    final random = Random();
    candleData = List.generate(50, (index) {
      final open = 50000 + random.nextDouble() * 10000;
      final close = open + (random.nextDouble() - 0.5) * 2000;
      final high = max(open, close) + random.nextDouble() * 1000;
      final low = min(open, close) - random.nextDouble() * 1000;
      return CandleData(
        index: index,
        open: open,
        high: high,
        low: low,
        close: close,
      );
    });
  }

  void _startAnalysis() {
    setState(() {
      isAnalyzing = true;
      expiryTime = 60;
    });

    // Simulate analysis delay
    Future.delayed(const Duration(seconds: 2), () {
      _generateSignal();
    });
  }

  void _generateSignal() {
    final random = Random();
    final signal = random.nextBool() ? 'CALL' : 'PUT';
    final confidenceValue = 95.0 + random.nextDouble() * 5.0; // 95-100%

    setState(() {
      currentSignal = signal;
      confidence = confidenceValue;
      isAnalyzing = false;
    });

    _startExpiryTimer();
  }

  void _startExpiryTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        expiryTime--;
        if (expiryTime <= 0) {
          timer.cancel();
          currentSignal = 'Expired';
          _startAnalysis();
        }
      });
    });
  }

  void _placeTrade(String option) {
    // In a real app, this would send the trade to the API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trade placed: $option on $selectedAsset')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binomo Signal App'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Asset Selection
            DropdownButton<String>(
              value: selectedAsset,
              onChanged: (String? newValue) {
                setState(() {
                  selectedAsset = newValue!;
                  _startAnalysis();
                });
              },
              items: assets.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Chart
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: candleData.map((data) => FlSpot(data.index.toDouble(), data.close)).toList(),
                          isCurved: false,
                          color: Colors.blue,
                          barWidth: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Signal Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    isAnalyzing ? 'Analyzing Market...' : 'Signal: $currentSignal',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (!isAnalyzing)
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                  Text(
                    'Expires in: $expiryTime seconds',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Call/Put Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentSignal == 'CALL' ? () => _placeTrade('CALL') : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('CALL UP', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentSignal == 'PUT' ? () => _placeTrade('PUT') : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('PUT DOWN', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Technical Indicators
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Technical Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• RSI: 65.4 (Neutral)'),
                  Text('• MACD: Bullish crossover'),
                  Text('• Moving Average: Above 50-period'),
                  Text('• Support/Resistance: Near resistance level'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CandleData {
  final int index;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.index,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}