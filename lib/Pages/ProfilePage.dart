import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docscheduler/Pages/SpecilityPage.dart';
import 'package:docscheduler/auth/auth_services.dart';
import 'package:docscheduler/Pages/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'John Doe';
  String _email = 'johndoe@example.com';
  bool _isLoading = true;
  bool _isEditing = false; // Toggle for edit mode
  final _authServices = AuthServices();
  String _profileImageUrl = '';
  File? _imageFile; // Store new profile image

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? user = _authServices.getCurrentUser(); // Fetch the current user using getCurrentUser()

      print(user);
      if (user != null) {
        // Fetch user details from Firestore based on UID
        DocumentSnapshot userProfile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        print(userProfile.data());
        setState(() {
          _name = userProfile['name'] ?? 'Anonymous'; // default if name is null
          _email = userProfile['email'] ?? user.email!;
          _profileImageUrl = userProfile['profileImageUrl'] ?? '';

          _nameController.text = _name;
          _emailController.text = _email;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload profile picture to Firebase Storage
  Future<String?> _uploadProfilePicture(File imageFile) async {
    try {
      User? user = _authServices.getCurrentUser();
      if (user != null) {
        String filePath = 'profile_images/${user.uid}.jpg';
        UploadTask uploadTask =
        FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
    return null;
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      User? user = _authServices.getCurrentUser();

      if (user != null) {
        // If there's a new image, upload it and get the new URL
        if (_imageFile != null) {
          String? newImageUrl = await _uploadProfilePicture(_imageFile!);
          if (newImageUrl != null) {
            _profileImageUrl = newImageUrl;
          }
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'profileImageUrl': _profileImageUrl,
        });
        await FirebaseFirestore.instance.collection('patients').doc(user.uid).update({
          'name': _nameController.text,
          'imageUrl': _profileImageUrl,
        });

        setState(() {
          _name = _nameController.text;
          _isEditing = false; // Switch back to view mode after saving
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile.')),
        );
      }
  }

  void logout() {
    final auth = AuthServices();
    auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal[300],
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile(); // Save changes when save icon is clicked
              } else {
                setState(() {
                  _isEditing = true; // Switch to edit mode
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Loader
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : AssetImage('assets/user.jpg')) as ImageProvider,
                radius: 60.0,
              ),
              if (_isEditing)
                TextButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Change Profile Picture'),
                  onPressed: _pickImage, // Pick an image only in edit mode
                ),
              SizedBox(height: 20.0),

              // Name field (editable only in edit mode)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                readOnly: !_isEditing, // Make it non-editable in view mode
              ),
              SizedBox(height: 10.0),

              // Email field (always read-only)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // Email is always read-only
              ),
              SizedBox(height: 30.0),

              ElevatedButton(
                onPressed: () => {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SpecialityPage())
                  )
                },
                child: Text('Specility'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
