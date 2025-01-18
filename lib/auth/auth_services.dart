import 'dart:io';

import 'package:docscheduler/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/db_service.dart';
import 'package:docscheduler/global.dart';

class AuthServices{
  //instance of auth
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  // sign in
  Future<UserCredential> signInWithEmailAndPassword(String email,String password ) async {
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password );
      return userCredential;
    } on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }

  Future<String> uploadProfileImage(File imageFile, String uid) async {
    try {
      // Define the path in Firebase Storage where the image will be stored
      Reference storageReference = FirebaseStorage.instance.ref().child('profileImages/$uid.jpg');

      // Upload the file
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("File uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      throw Exception('Failed to upload profile image.');
    }
  }

  // sign up
  Future<UserCredential> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      Role role,
      File imageFile, // Assuming the image file is passed as an argument
      ) async {
    try {
      // 1. Create the user with email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Upload the profile image and get its URL
      String imageUrl = await uploadProfileImage(imageFile, userCredential.user!.uid);

      // 3. Create the appropriate user object (Doctor or Patient)
      AppUser newUser;
      if (role == Role.doctor) {
        newUser = Doctor(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          specializations: [],  // Add specializations if needed
          imageUrl: imageUrl,   // Use the uploaded image URL
        );
      } else {
        newUser = Patient(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          medicalHistory: [],    // Add medical history if needed
          imageUrl: imageUrl,    // Use the uploaded image URL
        );
      }

      // 4. Add user data to the database
      await _dbService.addUserData(newUser);

      // 5. Return the user credential
      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);  // Handle Firebase exceptions
    }
  }


  // sign out
  Future<void> signOut() async {
    return await auth.signOut();
  }

  // get current user
  User? getCurrentUser() {
    return auth.currentUser!;
  }
}