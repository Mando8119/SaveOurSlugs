import 'package:flutter/material.dart';
import 'package:ussd_phone_call_sms/ussd_phone_call_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_background_video_recorder/flutter_bvr.dart';
import 'package:flutter_background_video_recorder/flutter_bvr_channel.dart';
import 'package:flutter_background_video_recorder/flutter_bvr_platform_interface.dart';


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
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 27, 66, 196)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SaveOurSlugs'),
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
  String place = 'even';
  // ignore: unused_element
  void _incrementCounter() {
    setState(() {
      counter++;
      if (counter % 2 == 0){
        place = 'even';
      }else{place = 'odd';}
    });
  }

Future<void> _requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.phone,
      Permission.location,
      Permission.videos,
      Permission.microphone,
      Permission.camera,
      // Add other permissions you need here
    ].request();

    // Handle the permission request result
    if (statuses[Permission.sms]!.isGranted && statuses[Permission.phone]!.isGranted) {
      // All requested permissions are granted
      // ignore: avoid_print
      print('All permissions granted');
    } else {
      // Handle the case where permissions are denied
      // ignore: avoid_print
      print('One or more permissions denied');
    }
  }
  //  THIS METHOD SHOULD ALSO REQUEST GPS LOCATION
void _call() async {
  await _requestAllPermissions();
  var phoneStatus = await Permission.phone.status;
  if (phoneStatus.isGranted) {
    try {
      await UssdPhoneCallSms().phoneCall(phoneNumber: '+15043305685');
      // ignore: avoid_print
      print('Phone call successful');
    } catch (e) {
      // ignore: avoid_print
      print('Error making phone call: $e');
    }
  } else {
    // ignore: avoid_print
    print('Phone call permission denied');
  }
}

void _sendSMS() async {
  await _requestAllPermissions();
  var smsStatus = await Permission.sms.status;
  if (smsStatus.isGranted) {
    _incrementCounter();
    try {
      await UssdPhoneCallSms().textMultiSMS(
        recipientsList: ['+15043305685'], // Replace with actual phone number(s)
        smsBody: 'This message was sent $counter times, that is an $place',
      );
      // ignore: avoid_print
      print('Successful');
    } catch (e) {
      // ignore: avoid_print
      print('Error sending SMS: $e');
    }
  } else {
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
            onPressed: _call,
            child: const Text('-1-------'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: _sendSMS,
            child: const Text('--2-------'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () 
              {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const UserInformation(title: 'UserInformation');
              }));
            },
            child: const Text('---3-----'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: _requestAllPermissions,//set here for now but should be moved to first ever button of app
            child: const Text('---4-----'),
          ),
        ],
      ),
    );
  }   
}
class UserInformation extends StatelessWidget {
  const UserInformation({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 45));

    return Center(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () {Navigator.pop(context);},
              child: const Text('Go Back'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: style,
              onPressed: () 
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const UserInformation1(title: 'UserInformation1');
                }));
              }, 
              child: const Text('---3-----'),)
          ]
        )
    );
    
  }
}
class UserInformation1 extends StatelessWidget {  
  const UserInformation1({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
            decoration: const InputDecoration(
              hintText: 'Please enter your full name:',
            )
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Please enter your email:',
              )
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {}, 
              child: const Text("Submit")
            )
            
    
          
    
            
          ]
        )
      )
    );
  }
}
  