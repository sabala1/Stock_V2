import 'package:flutter/material.dart';
import 'package:stock_v2/views/stock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'Stock App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    home:Stock()
    );
  }
}
