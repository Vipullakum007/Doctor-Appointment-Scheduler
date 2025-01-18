import 'package:docscheduler/Pages/ViewAppoinment.dart';
import 'package:docscheduler/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:docscheduler/Pages/Login.dart';
import 'package:docscheduler/Pages/MyRegister.dart';
import 'package:flutter/material.dart';
import 'Pages/ProfilePage.dart';
import 'package:docscheduler/Pages/AppointmentBookingPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocScheduler',
      theme: ThemeData(

      primarySwatch: Colors.blue,

      ),
      home: AuthGate(),
      routes: {
        '/profile' : (context) => ProfilePage(),
        '/register' : (context) => MyRegister(),
        '/login' : (context) => Login(),
        '/viewappointment': (context) => ViewAppointmentsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


