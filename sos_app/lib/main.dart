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

  int counter = 0;
  // ignore: unused_element
  void _incrementCounter() {
    setState(() {
      counter++;
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
    _incrementCounter();
    await _requestPermission();
    var smsStatus = await Permission.sms.status;
    if (smsStatus.isGranted) {
      try {
        await UssdPhoneCallSms().textMultiSMS(
          recipientsList: ['+18312339795'], // Replace with actual phone number(s)
          smsBody: 'Dumbass UI/UX mofo. This message was sent $counter times',
        );
        //ignore: avoid_print
        print('Successful');
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
            child: const Text('----------'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: _sendSMS,
            child: const Text('----------'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {},
            child: const Text('----------'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {},
            child: const Text('----------'),
          ),
        ],
      ),
    );
  }

      
  }