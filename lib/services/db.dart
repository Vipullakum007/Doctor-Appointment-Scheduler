import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:docscheduler/global.dart';
class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // Collection reference
  final CollectionReference appointmentCollection = FirebaseFirestore.instance.collection('appointments');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> addUserData( {required String name,required String email , required String password , required Role role }  ) async{
    return await userCollection.doc(uid).set({
      'name':name,
      'email':email,
      'password':password,
      'role':role.toString().split('.').last,
    });
  }

  // Future<void> updateUser(String id, String name, String email, String password, Role role) async {
  //   return await userCollection.doc(id).update({
  //     'name': name,
  //     'email': email,
  //     'password': password,
  //     'role': role.toString().split('.').last,
  //   });
  // }
  Future<void> updateUser(String id, String name, String email) async {
    return await userCollection.doc(id).update({
      'name': name,
      'email': email,

    });
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    return await userCollection.doc(id).delete();
  }

  Stream<List<AppUser>> getUsers() {
    return userCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc);
      }).toList();
    });
  }

  Future<AppUser> getUserById(String id) async {
    DocumentSnapshot doc = await userCollection.doc(id).get();
    return AppUser.fromMap(doc);
  }

  // Add a new appointment
  Future<void> addAppointment(String id, String patientName, String doctorName, DateTime appointmentDate) async {
    return await appointmentCollection.doc(id).set({
      'patientName': patientName,
      'doctorName': doctorName,
      'appointmentDate': appointmentDate,
    });
  }

  // Update an existing appointment
  Future<void> updateAppointment(String id, String patientName, String doctorName, DateTime appointmentDate) async {
    return await appointmentCollection.doc(id).update({
      'patientName': patientName,
      'doctorName': doctorName,
      'appointmentDate': appointmentDate,
    });
  }

  // Delete an appointment
  Future<void> deleteAppointment(String id) async {
    return await appointmentCollection.doc(id).delete();
  }

  // Get a list of all appointments
  Stream<List<Appointment>> getAppointments() {
    return appointmentCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appointment(
          id: doc.id,
          patientName: doc['patientName'],
          doctorName: doc['doctorName'],
          appointmentDate: (doc['appointmentDate'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // Get a specific appointment by ID
  Future<Appointment> getAppointmentById(String id) async {
    DocumentSnapshot doc = await appointmentCollection.doc(id).get();
    return Appointment(
      id: doc.id,
      patientName: doc['patientName'],
      doctorName: doc['doctorName'],
      appointmentDate: (doc['appointmentDate'] as Timestamp).toDate(),
    );
  }
}

// Define an Appointment model for easier data handling
class Appointment {
  final String id;
  final String patientName;
  final String doctorName;
  final DateTime appointmentDate;

  Appointment({required this.id, required this.patientName, required this.doctorName, required this.appointmentDate});
}

class AppUser {
  final String name;
  final String email;
  final String password;
  final Role role;

  AppUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last, // Converts the enum to a string
    };
  }

  // Create an AppUser object from a Firestore document snapshot
  factory AppUser.fromMap(DocumentSnapshot doc) {
    return AppUser(
      name: doc['name'],
      email: doc['email'],
      password: doc['password'],
      role: Role.values.firstWhere((e) => e.toString() == 'Role.' + doc['role']),
    );
  }
}
