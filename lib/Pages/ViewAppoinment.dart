import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAppointmentsPage extends StatefulWidget {
  @override
  _ViewAppointmentsPageState createState() => _ViewAppointmentsPageState();
}

class _ViewAppointmentsPageState extends State<ViewAppointmentsPage> {
  User? currentUser;
  bool _isLoading = true;
  List<DocumentSnapshot> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment deleted successfully')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment')),
      );
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      currentUser = FirebaseAuth.instance.currentUser;
      print(currentUser!.uid);
      if (currentUser != null) {
        QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: currentUser!.uid)
            .orderBy('appointmentDate', descending: false)
            .get();

        setState(() {
          _appointments = appointmentsSnapshot.docs;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Appointment"),
          content: Text("Are you sure you want to delete this appointment?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAppointment(appointmentId); // Delete appointment
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Appointments'),
        backgroundColor: Colors.teal[300],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? Center(child: Text('No appointments found.'))
          : ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          DocumentSnapshot appointment = _appointments[index];
          String appointmentId = appointment['appointmentId'];
          print(appointment['appointmentId']);
          String status = appointment['status'];
          Color cardColor;

          // Set background color based on the appointment status
          if (status == 'Pending') {
            cardColor = Colors.yellow[200]!;
          } else if (status == 'Rejected' || status == 'Cancelled') {
            cardColor = Colors.red[200]!;
          } else if (status == 'Completed') {
            cardColor = Colors.green[200]!;
          } else {
            cardColor = Colors.grey[200]!; // Default background color
          }

          return Card(
            color: cardColor,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              title: Text(
                'Doctor: ${appointment['doctorName']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text('Date: ${appointment['appointmentDate']}'),
                  Text('Time Slot: ${appointment['slotTime']}'),
                  SizedBox(height: 5),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                        color: status == 'Pending'
                            ? Colors.orange[800]
                            : status == 'Rejected' || status == 'Cancelled'
                            ? Colors.red[800]
                            : Colors.green[800],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                // String appointmentId = appointment["appointmentId"],
                onPressed: () {
                  _showDeleteConfirmationDialog(appointmentId);
                },
              ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/bookappointment'); // Example: Redirect to booking page
      //   },
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.orange[600],
      // ),
    );
  }
}
