import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String appointmentId;
  final String patientName;
  final String phoneNumber;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String notes;

  Appointment({
    required this.appointmentId,
    required this.patientName,
    required this.phoneNumber,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes = "",
  });

  // Factory method to create an Appointment object from Firestore document
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Appointment(
      appointmentId: doc.id,
      patientName: data['patientName'] ?? 'Unknown',
      phoneNumber: data['phoneNumber'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      status: data['status'] ?? 'Pending',
      notes: data['notes'] ?? '',
    );
  }

  // Method to map Appointment object to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'status': status,
      'notes': notes,
    };
  }
}
