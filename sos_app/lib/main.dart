import 'package:flutter/material.dart';
import 'package:ussd_phone_call_sms/ussd_phone_call_sms.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Our Slugs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Save Our Slugs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _multiplyer = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _multiplyer = _counter * 14;
    });
  }

  // Function to send SMS
  void _sendSMS() async {
    try {
      await UssdPhoneCallSms().textMultiSMS(
        recipientsList: ['+7606429239'], // Replace with actual phone number
        smsBody: 'Hello, this is a test message!',
      );
    } catch (e) {
      // Handle any errors here
      // ignore: avoid_print
      print('Error sending SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: Container(
        height: 67,
        width: 300,
        color: const Color.fromARGB(8, 3, 77, 237),
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _sendSMS,
          child: const Center(
            child: Text("Push Button For Sex!!\nHot singles in your area!"),
     )
        )
      )
    );
      
  }

      
  }