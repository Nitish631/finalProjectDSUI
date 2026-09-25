import 'package:flutter/material.dart';
import 'package:medicom/screens/user_interface.dart';


void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "First Aid",
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:MainPage()


    );
  }
}