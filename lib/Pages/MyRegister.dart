import 'package:docscheduler/Pages/HomeScreen.dart';
import 'package:docscheduler/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'AppointmentSchedulePage.dart';
import 'Login.dart';
import 'package:docscheduler/global.dart';
import '../components/error_dialog.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final authService = AuthServices();
  Role? _selectedRole;
  File? _image; // Field to hold the selected image

  final picker = ImagePicker();

  // Image picking method
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print("Picked image: ${_image!.path}");
      } else {
        ErrorDialog.show(context,"No image selected.");
      }
    });
  }


  void register(BuildContext context) async {
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        if (_selectedRole != null) {
          if (_image != null) {
            // Pass the image file to the authService's sign up method
            UserCredential userCredential = await authService.signUpWithEmailAndPassword(
              _emailController.text,
              _passwordController.text,
              _nameController.text,
              _selectedRole!,
              _image!, // Pass the selected image file
            );
            String uid = userCredential.user!.uid;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account Created successfully!')),
            );
            print(_selectedRole);
            // String role = _selectedRole
            if(_selectedRole == Role.doctor){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AppointmentsPage(doctorId: uid)),
              );
            }
            else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          } else {
            ErrorDialog.show(context, "Please upload a profile image.");
          }
        } else {
          ErrorDialog.show(context, "Please select a role.");
        }
      } catch (e) {
        ErrorDialog.show(context, e.toString());
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match!"),
        ),
      );
    }
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
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<Role>(
                      value: _selectedRole,
                      hint: const Text("Select Role"),
                      items: Role.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (role) {
                        setState(() {
                          _selectedRole = role;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => register(context),
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: const Text(
                        'Already an Account? Sign In',
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
