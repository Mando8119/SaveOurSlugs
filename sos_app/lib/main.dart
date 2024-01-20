import 'package:flutter/material.dart';
import 'package:ussd_phone_call_sms/ussd_phone_call_sms.dart';
import 'package:permission_handler/permission_handler.dart';



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
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 80, 33, 101)),
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
  Future<void> _requestPermission() async {
  var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
  }

  void _sendSMS() async {
    await _requestPermission();
    var smsStatus = await Permission.sms.status;
    if (smsStatus.isGranted) {
      try {
        await UssdPhoneCallSms().textMultiSMS(
          recipientsList: ['+1234567890'], // Replace with actual phone number(s)
          smsBody: 'Hello, this is a test message!',
        );
      } catch (e) {
        // Handle any errors here
        // ignore: avoid_print
        print('Error sending SMS: $e');
      }
    } else {
      // Handle the case when permission is denied
      // ignore: avoid_print
      print('SMS permission denied');
    }
  }

    @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 45));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            style: style,
            onPressed: () {},
            child: const Text('Call Police'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {},
            child: const Text('Text Police'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {},
            child: const Text('Alert Emergency Contact'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {},
            child: const Text('Record GPS and Camera'),
          ),
        ],
      ),
    );
  }

      
  }