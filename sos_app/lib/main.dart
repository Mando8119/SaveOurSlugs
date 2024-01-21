import 'package:flutter/material.dart';
import 'package:flutter_background_video_recorder/flutter_bvr_channel.dart';
import 'package:flutter_background_video_recorder/flutter_bvr_platform_interface.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:ussd_phone_call_sms/ussd_phone_call_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_background_video_recorder/flutter_bvr.dart';
import 'package:mailer/mailer.dart';


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

  bool _isRecording = false;
  bool _recorderBusy = false;
  StreamSubscription<int?>? _streamSubscription;
  final _flutterBackgroundVideoRecorderPlugin = FlutterBackgroundVideoRecorder();
  // ignore: unused_element
  void _incrementCounter() {
    setState(() {
      counter++;
      if (counter % 2 == 0){
        place = 'even';
      }else{place = 'odd';}
    });
  }

@override
  /*void initState() {
    super.initState();
    getInitialRecordingStatus();
    listenRecordingState();
  }*/

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /*Future<void> getInitialRecordingStatus() async {
    _isRecording = await _flutterBackgroundVideoRecorderPlugin.getVideoRecordingStatus() == 1;
  }

  void listenRecordingState() {
    _streamSubscription = _flutterBackgroundVideoRecorderPlugin.recorderState.listen((event) {
      setState(() {
        switch (event) {
          case 1:
            _isRecording = true;
            _recorderBusy = true;
            break;
          case 2:
            _isRecording = false;
            _recorderBusy = false;
            break;
          case 3:
            _recorderBusy = true;
            break;
          case -1:
            _isRecording = false;
            _recorderBusy = false;
            break;
          default:
            break;
        }
      });
    });
  }

  Future<void> startRecording() async {
    if (!_isRecording && !_recorderBusy) {
      await _flutterBackgroundVideoRecorderPlugin.startVideoRecording(
        folderName: "Example Recorder",
        cameraFacing: CameraFacing.frontCamera,
        notificationTitle: "Example Notification Title",
        notificationText: "Example Notification Text",
        showToast: false
      );
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      String filePath = await _flutterBackgroundVideoRecorderPlugin.stopVideoRecording() ?? "None";
      debugPrint(filePath);
    }
  }
  */

Future<void> _requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.phone,
      Permission.location,
      Permission.videos,
      Permission.microphone,
      Permission.camera,
      Permission.storage,
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

/*Future<void> sendingmail() async{

  try{
    var userEmail = 'saveourslugs2024@gmail.com';
    var message = Message();
    message.subject = 'Subeject from Flutter';
    message.text = 'Yo... sent from Flutter';
    message.from = const Address('saveourslugs2024@gmail.com');
    message.recipients.add('saveourslugs@gmail.com');
    var smptServer = gmailSaslXoauth2(userEmail, accessToken)
    send(message, smptServer);
    print('Email has been sent successfully.')
  }catch (e) {
    print('Error sending E-Mail: $e');
  }
}*/
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
        smsBody: '',
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
            child: const Text('Call'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: _sendSMS,
            child: const Text('Send SMS'),
          ),
          const SizedBox(height: 30),
      
          ElevatedButton(
            style: style,
            onPressed: _requestAllPermissions,//set here for now but should be moved to first ever button of app
            child: const Text('Request Permissions'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const UserInformation(title: 'UserInformation');
              }));
            },
            child: const Text('User Information'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () 
              {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const EmergencyContact(title: 'EmergencyContact');
              }));
            },
            child: const Text('Set Emergency Contact'),
          ),
          const SizedBox(height: 30),
          /*const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: sendingmail,
            child: const Text('Send E-Mail'),
          ),*/
        ],
      ),
    );
  }   
}

// PERSONAL INFO 1
// PERSONAL INFO 1
// PERSONAL INFO 1
// PERSONAL INFO 1
// PERSONAL INFO 1
class UserInformation extends StatefulWidget {
  const UserInformation({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  // TextEditingControllers to retrieve the current value of TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Retrieve the values from the controllers
    String name = _nameController.text;
    String email = _emailController.text;

    // Use the values as needed
    print('Name: $name, Email: $email');

    // Add your logic to handle the submitted data
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Please enter your full name:',
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Please enter your date of birth:',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const UserInformation1(title: 'UserInformation1');
              }));
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}


//PERSONAL INFO 2
//PERSONAL INFO 2
//PERSONAL INFO 2
//PERSONAL INFO 2

class UserInformation1 extends StatefulWidget {
  const UserInformation1({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UserInformation1State createState() => _UserInformation1State();
}

class _UserInformation1State extends State<UserInformation1> {
  // TextEditingControllers to retrieve the current value of TextFormFields
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _sexController.dispose();
    _raceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Retrieve the values from the controllers
    String sex = _sexController.text;
    String race = _raceController.text;

    // Use the values as needed
    print('Name: $sex, Email: $race');

    // Add your logic to handle the submitted data
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _sexController,
              decoration: const InputDecoration(
                hintText: 'Please enter your Sex:',
              ),
            ),
            TextFormField(
              controller: _raceController,
              decoration: const InputDecoration(
                hintText: 'Please enter your Race:',
              ),
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const UserInformation2(title: 'UserInformation2');
              }));
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}


//PERSONAL INFO 3
//PERSONAL INFO 3
//PERSONAL INFO 3
//PERSONAL INFO 3

class UserInformation2 extends StatefulWidget {
  const UserInformation2({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UserInformation2State createState() => _UserInformation2State();
}

class _UserInformation2State extends State<UserInformation2> {
  // TextEditingControllers to retrieve the current value of TextFormFields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _heightController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Retrieve the values from the controllers
    String height= _heightController.text;
    String email = _emailController.text;
    String weight = _weightController.text;

    // Use the values as needed
    print('Name: $height, Email: $email, Weight: $weight');
    // Add your logic to handle the submitted data
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                hintText: 'Please enter your email:',
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Please enter your height:',
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Please enter your weight:',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const MyHomePage(title: 'MyHomePage');
              }));
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
class EmergencyContact extends StatefulWidget {
  const EmergencyContact({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _EmergencyContactState createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  // TextEditingControllers to retrieve the current value of TextFormFields
  final TextEditingController _ecNameController = TextEditingController();
  final TextEditingController _ecEmailController = TextEditingController();
  final TextEditingController _ecPhoneController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _ecNameController.dispose();
    _ecEmailController.dispose();
    _ecPhoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Retrieve the values from the controllers
    String ecName= _ecNameController.text;
    String ecEmail = _ecEmailController.text;
    String ecPhone = _ecPhoneController.text;

    // Use the values as needed
    print('Name: $ecName, Email: $ecEmail, Weight: $ecPhone');
    // Add your logic to handle the submitted data
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _ecNameController,
              decoration: const InputDecoration(
                hintText: "Please enter your emergency contact's full name:",
              ),
            ),
            TextFormField(
              controller: _ecEmailController,
              decoration: const InputDecoration(
                hintText: "Please enter your emergency contact's email:",
              ),
            ),
            TextFormField(
              controller: _ecPhoneController,
              decoration: const InputDecoration(
                hintText: "Please enter your emergency contact's phone number:",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const MyHomePage(title: 'MyHomePage');
              }));
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

