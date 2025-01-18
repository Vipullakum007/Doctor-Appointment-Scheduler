import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docscheduler/auth/auth_services.dart';
import 'package:docscheduler/services/doctor_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfilePage.dart';
import 'AppointmentBookingPage.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _doctors = [];
  List<Map<String, String>> _filteredDoctors = [];
  final CollectionReference _doctorsCollection =  FirebaseFirestore.instance.collection('doctors');
  final _doctorService = DoctorService();
  final _authService = AuthServices();
  bool _isLoading = true;
  String _patientName = 'User';

  void _logout() async {
    await _authService.signOut(); // Assuming you have an AuthService with signOut method
    Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login screen after logout
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchPatientName();
    _filteredDoctors = _doctors;
    _searchController.addListener(() {
      setState(() {
        _filteredDoctors = _filterDoctors(_doctors);
      });
    });
  }

  Future<void> _fetchPatientName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot patientDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(currentUser.uid)
            .get();

        if (patientDoc.exists) {
          setState(() {
            _patientName = patientDoc['name'];
            print(_patientName);
          });
        }
      }
    } catch (e) {
      print('Error fetching patient name: $e');
    }
  }

  void _fetchDoctors() async {
    try {
      List<Map<String, String>> doctors = await _doctorService.getDoctorsList();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = _doctors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, String>> _filterDoctors(List<Map<String, String>> doctors) {
    String query = _searchController.text.toLowerCase();
    return doctors.where((doctor) {
      return doctor['name']!.toLowerCase().contains(query) ||
          doctor['specialization']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              MaterialPageRoute(builder: (context) => ProfilePage()), // Navigate to Profile Page
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
            RichText(
              text: TextSpan(
                text: 'Welcome, ',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto-Regular',
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: _patientName, // Display patient's name here
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search for doctors',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20.0),
            const Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            _isLoading
                ? const Expanded(
              child: Center(
                child: CircularProgressIndicator(), // Loader
              ),
            )
                : Expanded(
              child: _filteredDoctors.isEmpty
                  ? Center(child: Text('No doctors found'))
                  : ListView.builder(
                itemCount: _filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = _filteredDoctors[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/dpp.png'),
                    ),
                    title: Text(doctor['name']!),
                    subtitle: Text(doctor['specialization']!),
                    onTap: () {
                      // print('Tapped!!');
                      // print(doctor);
                      // print(doctor['doctor_id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentBookingPage(
                            doctorId: doctor['doctor_id']!, // Pass doctor ID here
                            doctorName: doctor['name']!, // Pass doctor name here
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/viewappointment');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[600],
      ),
    );
  }
}
