import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docscheduler/Pages/AppointmentSchedulePage.dart';
import 'package:docscheduler/Pages/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:docscheduler/auth/auth_services.dart';
import 'MyRegister.dart';
import 'package:docscheduler/global.dart';
import '../components/error_dialog.dart';
import 'package:local_auth/local_auth.dart';


class Login extends StatefulWidget {
  const Login({super.key});


  @override
  State<Login> createState() => _LoginState();
}


class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authService = AuthServices();
  final LocalAuthentication auth = LocalAuthentication();
  bool _isLoading = false;

  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAvailability();
  }

  Future<void> _checkBiometricsAvailability() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
      _availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {}); // Trigger UI update if the availability changes
    } catch (e) {
      print("Error checking biometrics: $e");
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      _isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (_isAuthenticated) {
        // If authenticated, perform the login
        _loginWithSavedCredentials();
      }
    } catch (e) {
      print("Error during biometric authentication: $e");
    }
  }

  // Login using previously saved credentials
  Future<void> _loginWithSavedCredentials() async {
    // Fetch the saved credentials from secure storage (if needed)
    // Here, for demonstration, we are using static credentials
    String savedEmail = "your_saved_email@example.com"; // Replace this with actual saved credentials
    String savedPassword = "your_saved_password";       // Replace this with actual saved credentials

    _emailController.text = savedEmail;
    _passwordController.text = savedPassword;

    // Perform the normal login
    login(context);
  }

  Future<void> login(BuildContext context) async {
    try {
      UserCredential userCredential = await authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      print(userCredential.user?.uid);
      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successfully!')),
        );
        print(_emailController.text + " " + _passwordController.text);

        String role = userDoc['role'];

        if (role == 'doctor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppointmentsPage(doctorId: uid)),
          );
        } else if (role == 'patient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      ErrorDialog.show(context, e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_rounded, color: Colors.grey),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => login(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // if (_canCheckBiometrics) // Only show if biometrics are available
                    //   ElevatedButton.icon(
                    //     onPressed: _authenticateWithBiometrics,
                    //     icon: const Icon(Icons.fingerprint),
                    //     label: const Text('Login with Biometrics'),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.green,
                    //       padding: const EdgeInsets.symmetric(vertical: 15.0),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10.0),
                    //       ),
                    //     ),
                    //   ),
                    // const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyRegister()),
                        );
                      },
                      child: const Text(
                        'Want to create Account?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
