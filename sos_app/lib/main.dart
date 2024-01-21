import 'package:flutter/material.dart';
import 'package:flutter_background_video_recorder/flutter_bvr_channel.dart';
import 'package:flutter_background_video_recorder/flutter_bvr_platform_interface.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:ussd_phone_call_sms/ussd_phone_call_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_background_video_recorder/flutter_bvr.dart';
import 'package:mailer/mailer.dart';
import 'package:gallery_saver/gallery_saver.dart';


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
class GoogleAuthApi {
  static final _googleSignIn = GoogleSignIn(scopes: ['https://mail.google.com/']);

  static Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }
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
  void initState() {
    super.initState();
    getInitialRecordingStatus();
    listenRecordingState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> getInitialRecordingStatus() async {
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

    // Save the recorded file to the gallery
    try {
      bool success = (await GallerySaver.saveVideo(filePath)) ?? false;
      print("Video saved to gallery: $success");
    } catch (e) {
      // ignore: avoid_print
      print('Error sending video: $e');
    }
  }
}
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

  Future<void> sendingmail() async{
  final user = await GoogleAuthApi.signIn();

  if (user == null) return;
  final email = user.email;
  final auth = await user.authentication;
  final token = auth.accessToken!;

  final smtpServer = gmailSaslXoauth2(email, token);

  final message = Message()
    ..from = Address(email, 'User')
    ..recipients = [email]
    ..subject = 'Incident Report'
    ..text = 'This report is meant to provide vital information including an attachment of the video feed captured from the incident.';

  try{
    await send(message, smtpServer);
    print('Email sent successfully');
  }on MailerException catch (e) {
    print('Email not successful: $e');
  }
}
  //  THIS METHOD SHOULD ALSO REQUEST GPS LOCATION
void _call() async {
  await _requestAllPermissions();
  startRecording();
  sendingmail();
  var phoneStatus = await Permission.phone.status;
  if (phoneStatus.isGranted) {
    try {
      await UssdPhoneCallSms().phoneCall(phoneNumber: '+18312339795'); //would be 911, however we don't want cops showing up for demonstration
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
  startRecording();
  sendingmail();
  var smsStatus = await Permission.sms.status;
  if (smsStatus.isGranted) {
    _incrementCounter();
    try {
      await UssdPhoneCallSms().textMultiSMS(
        recipientsList: ['+18312339795'], // Replace with actual emergency contact
        smsBody: 'This message would contain vital information to your emergency contact of the incident.',
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/SOS.png', // Replace with your image asset path
              fit: BoxFit.cover,
            ),
          ),

          // Positioned invisible ElevatedButtons
          _buildPositionedButton(
            left: 145,
            top: 80,
            width: 140,
            height: 150,
            onPressed: _call,
            text: 'Call',
          ),
          _buildPositionedButton(
            left: 145,
            top: 260,
            width: 140,
            height: 150,
            onPressed: _sendSMS,
            text: 'Send SMS',
          ),
          _buildPositionedButton(
            left: 7,
            top: 50,
            width: 55,
            height: 55,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const UserInformation(title: 'UserInformation');
              }));
            },
            text: 'User Information',
          ),
          _buildPositionedButton(
            left: 145,
            top: 450,
            width: 140,
            height: 150,
            onPressed: _sendSMS,
            text: 'Set Emergency Contact',
          ),
          _buildPositionedButton(
            left: 145,
            top: 630,
            width: 140,  // Set the width
            height: 150,  // Set the height
            onPressed: (){
              // Toggle between starting and stopping recording
              if (_isRecording) {
                stopRecording();
                } else {
                  startRecording();
                }
                  // Update recording state 
              },
              text: _isRecording ? 'Stop Recording' : 'Record Video',  // Change button text based on recording state
              ),
        ],
      ),
    );
  }

  Widget _buildPositionedButton({
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onPressed,
    required String text,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent, // Make the button background transparent
            onPrimary: Colors.transparent, // Make the button text transparent
            shadowColor: Colors.transparent, // Remove shadow
            elevation: 0, // Remove elevation
          ),
        ),
      ),
    );
  }
}

Widget _buildInvisibleButton(BuildContext context, {required VoidCallback onPressed, required double width, required double height}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: width,
      height: height,
      color: Colors.transparent, // Invisible hit area
    ),
  );
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/1.png', // Replace with your image asset path
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Please enter your full name:',
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Please enter your date of birth:',
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return const UserInformation1(title: 'UserInformation1');
                          }));
                        },
                        child: const Text("Continue"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Invisible ElevatedButton in the bottom right corner
          Positioned(
            bottom: 20, // Adjust the bottom margin as needed
            right: 20, // Adjust the right margin as needed
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const EmergencyContact(title: 'EmergencyContact');
                }));
              }, // Fixed the missing parenthesis here
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                onPrimary: Colors.transparent,
              ),
              child: null,
            ),
          ),
        ],
      ),
    );
  }
}









//PERSONAL INFO 2
//PERSONAL INFO 2
//PERSONAL INFO 2
//PERSONAL INFO 2

// User Information 1 Page
class UserInformation1 extends StatefulWidget {
  const UserInformation1({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UserInformation1State createState() => _UserInformation1State();
}

class _UserInformation1State extends State<UserInformation1> {
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();

  @override
  void dispose() {
    _sexController.dispose();
    _raceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String sex = _sexController.text;
    String race = _raceController.text;

    print('Sex: $sex, Race: $race');

    // Handle submitted data
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

// User Information 2 Page
class UserInformation2 extends StatefulWidget {
  const UserInformation2({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UserInformation2State createState() => _UserInformation2State();
}

class _UserInformation2State extends State<UserInformation2> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _heightController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String height = _heightController.text;
    String email = _emailController.text;
    String weight = _weightController.text;

    print('Height: $height, Email: $email, Weight: $weight');
    // Handle submitted data
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
              controller: _weightController,
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

// Emergency Contact Page
class EmergencyContact extends StatefulWidget {
  const EmergencyContact({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _EmergencyContactState createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  final TextEditingController _ecNameController = TextEditingController();
  final TextEditingController _ecEmailController = TextEditingController();
  final TextEditingController _ecPhoneController = TextEditingController();

  @override
  void dispose() {
    _ecNameController.dispose();
    _ecEmailController.dispose();
    _ecPhoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String ecName = _ecNameController.text;
    String ecEmail = _ecEmailController.text;
    String ecPhone = _ecPhoneController.text;

    print('Emergency Contact Name: $ecName, Email: $ecEmail, Phone: $ecPhone');
    // Handle submitted data
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