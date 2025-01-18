import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:docscheduler/global.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserData(AppUser user) async {
    // Add to 'users' collection
    await _firestore.collection('users').doc(user.uid).set({
      'name': user.name,
      'email': user.email,
      'role': user.role.toString().split('.').last,
      'profileImageUrl': user.imageUrl,
    });

    if (user.role == Role.doctor) {
      return await _firestore.collection('doctors').doc(user.uid).set(user.toMap());
    } else if (user.role == Role.patient) {
      return await _firestore.collection('patients').doc(user.uid).set(user.toMap());
    }
  }

  Future<AppUser?> getUserData(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return null;

    String role = userDoc['role'];
    if (role == 'doctor') {
      DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(uid).get();
      return Doctor.fromMap(doctorDoc.data() as DocumentSnapshot<Object?>);
    } else if (role == 'patient') {
      DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(uid).get();
      return Patient.fromMap(patientDoc.data() as DocumentSnapshot<Object?>);
    }
    return null;
  }

  Future<void> updateUserData(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'name': user.name,
      'email': user.email,
      'profileImageUrl': user.imageUrl,
    });

    // Update role-specific collection
    if (user.role == Role.doctor) {
      return await _firestore.collection('doctors').doc(user.uid).update(user.toMap());
    } else if (user.role == Role.patient) {
      return await _firestore.collection('patients').doc(user.uid).update(user.toMap());
    }
  }
}
