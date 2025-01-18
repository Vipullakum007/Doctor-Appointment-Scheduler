import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docscheduler/global.dart';


class AppUser {
  final String uid;
  final String name;
  final String email;
  final Role role;
  final String imageUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'imageUrl': imageUrl,
    };
  }

  factory AppUser.fromMap(DocumentSnapshot doc) {
    return AppUser(
      uid: doc.id,
      name: doc['name'],
      email: doc['email'],
      role: Role.values.firstWhere((e) => e.toString() == 'Role.' + doc['role']),
        imageUrl: doc['imageUrl'] ?? ''
    );
  }
}

class Doctor extends AppUser {
  final List<String> specializations;

  Doctor({
    required String uid,
    required String name,
    required String email,
    required this.specializations,
    required String imageUrl,
  }) : super(uid: uid, name: name, email: email, role: Role.doctor,imageUrl: imageUrl);

  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({'specializations': specializations});
  }

  factory Doctor.fromMap(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Doctor(
      uid: doc.id,
      name: doc['name'],
      email: doc['email'],
      specializations: List<String>.from(data['specializations'] ?? []),
        imageUrl: data['imageUrl'] ?? ''
    );
  }
}

class Patient extends AppUser {
  final List<String> medicalHistory;

  Patient({
    required String uid,
    required String name,
    required String email,
    required this.medicalHistory,
    required String imageUrl,
  }) : super(uid: uid, name: name, email: email, role: Role.patient,imageUrl: imageUrl);

  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({'medicalHistory': medicalHistory});
  }

  factory Patient.fromMap(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Patient(
      uid: doc.id,
      name: doc['name'],
      email: doc['email'],
      medicalHistory: List<String>.from(data['medicalHistory'] ?? []),
        imageUrl: data['imageUrl'] ?? ''
    );
  }

}
