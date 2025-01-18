import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment_model.dart';
import '../auth/auth_services.dart'; // Assuming you have a service for authentication
import '../Pages/DoctorProfilePage.dart';  // Assuming you have a profile page

class AppointmentsPage extends StatefulWidget {
  final String doctorId; // Pass the doctor ID to filter appointments

  AppointmentsPage({required this.doctorId});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<List<Appointment>> _appointmentsFuture;
  String _doctorName = 'Doctor'; // Placeholder for the doctor's name
  final _authService = AuthServices();
  // Fetch appointments for the doctor
  Future<List<Appointment>> _fetchAppointments(String doctorId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  // Fetch the doctor's name for display
  Future<void> _fetchDoctorName() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        setState(() {
          _doctorName = doctorDoc['name']; // Assuming 'name' is a field in the doctor document
        });
      }
    } catch (e) {
      print('Error fetching doctor name: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments(widget.doctorId);
    _fetchDoctorName(); // Fetch doctor's name on init
  }

  // Logout function
  void _logout() async {

    await _authService.signOut(); // Assuming you have an AuthService with signOut method
    Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login screen after logout
  }

  // Function to update appointment status
  void _updateAppointmentStatus(String appointmentId, String newStatus) {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': newStatus})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment status updated!')),
      );
      setState(() {
        _appointmentsFuture = _fetchAppointments(widget.doctorId);
      });
    }).catchError((e) {
      print('Error updating appointment status: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DocScheduler', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal[300],
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed:() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorProfilePage()), // Navigate to Profile Page
            );
          },   // Call the logout function
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout ,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, $_doctorName', // Display the doctor's name
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Appointments:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Appointment>>(
                future: _appointmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching appointments.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No appointments available.'));
                  }

                  // List of appointments
                  List<Appointment> appointments = snapshot.data!;
                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      Appointment appointment = appointments[index];

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Patient: ${appointment.patientName}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${appointment.appointmentDate}'),
                              // Text('Time: ${appointment.sloteTime}'),
                              Text('Status: ${appointment.status}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String newStatus) {
                              _updateAppointmentStatus(appointment.appointmentId, newStatus);
                            },
                            itemBuilder: (BuildContext context) {
                              return ['Scheduled', 'Completed', 'Cancelled']
                                  .map((String status) {
                                return PopupMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList();
                            },
                            child: Icon(Icons.more_vert),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
