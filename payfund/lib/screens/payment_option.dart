import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Stripe integration
import 'package:http/http.dart' as http; // HTTP package for API calls

class PaymentOption extends StatefulWidget {
  final int amount; // Amount passed from the Dashboard

  const PaymentOption({Key? key, required this.amount}) : super(key: key);

  @override
  _PaymentOptionState createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<PaymentOption> {
  bool _isProcessing = false; // Tracks whether a payment process is active

  Future<void> processStripePayment() async {
    if (_isProcessing) return; // Prevent multiple clicks

    setState(() {
      _isProcessing = true; // Start processing
    });

    try {
      // Backend endpoint ( this can be added to the firebase endpoint
      const String backendUrl =
          'BACKEND_URL_FOR_THE_INTENT';

      // Step 1: Create a PaymentIntent on your backend
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': widget.amount * 100, // Convert amount to cents
          'currency': 'usd', // Currency code
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to create PaymentIntent: ${response.body}',
        );
      }

      final paymentIntent = json.decode(response.body);

      // Step 2: Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Kurira International',
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'usd',
            testEnv: true, // Use test environment in development
          ),
          style: ThemeMode.system,
        ),
      );

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Notify the user of success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } catch (e) {
      String errorMessage = 'Payment failed';
      if (e is StripeException) {
        errorMessage = e.error.localizedMessage ?? errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isProcessing = false; // Reset the processing state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Option',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2.0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You are paying for airtime of \$${widget.amount}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null // Disable button if already processing
                      : processStripePayment,
                  icon: const Icon(Icons.credit_card, color: Colors.white),
                  label: _isProcessing
                      ? const Text(
                    'Processing...',
                    style: TextStyle(fontSize: 18),
                  )
                      : const Text(
                    'Pay with Card (Stripe)',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isProcessing ? Colors.grey : Colors.teal.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
