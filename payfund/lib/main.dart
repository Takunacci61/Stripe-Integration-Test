import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import Stripe package
import 'screens/dashboard.dart'; // Import the Dashboard screen

void main() {
  // Initialize Stripe with with the publishable key this can be added to firebase config
  Stripe.publishableKey = "STRIPE_PUBLISHABLE_KEY_HERE";

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Dashboard(), // Set Dashboard as the initial screen
    );
  }
}

