import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  AppointmentBookingPage({required this.doctorId, required this.doctorName});

  @override
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  DateTime? _selectedDate;
  String _slotTime = '';
  String _patientName = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _timeSlots = [];

  // Regex pattern to validate phone numbers (basic check for 10-digit numbers)
  final String phonePattern = r'^\d{10}$';

  @override
  void initState() {
    super.initState();
    _fetchPatientInfo();
    _generateTimeSlots();
  }

  Future<void> _fetchPatientInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser.uid)
          .get();

      if (patientDoc.exists) {
        setState(() {
          _patientName = patientDoc['name'];
        });
      }
    }
  }

  void _generateTimeSlots() {
    List<String> morningSlots = _generateSlotsInRange(10, 12);
    List<String> afternoonSlots = _generateSlotsInRange(15, 17); // 3:00 PM to 5:00 PM
    setState(() {
      _timeSlots = [...morningSlots, ...afternoonSlots];
    });
  }

  // Generate time slots in 15-minute intervals
  List<String> _generateSlotsInRange(int startHour, int endHour) {
    List<String> slots = [];
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        String timeSlot = _formatTimeSlot(hour, minute);
        slots.add(timeSlot);
      }
    }
    return slots;
  }

  // Format time slot as '10:00 AM', '10:15 AM', etc.
  String _formatTimeSlot(int hour, int minute) {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day, hour, minute);
    return time.hour < 12
        ? '${time.hour}:${time.minute.toString().padLeft(2, '0')} AM'
        : '${(time.hour == 12 ? 12 : time.hour - 12)}:${time.minute.toString().padLeft(2, '0')} PM';
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String appointmentId =
              FirebaseFirestore.instance.collection('appointments').doc().id;

          Map<String, dynamic> appointmentData = {
            'appointmentId': appointmentId,
            'doctorId': widget.doctorId,
            'doctorName': widget.doctorName,
            'patientId': user.uid,
            'patientName': _patientName,
            'phoneNumber': _phoneNumberController.text,
            'appointmentDate': _selectedDate?.toIso8601String() ?? '',
            'slotTime': _slotTime,
            'description': _descriptionController.text,
            'status': 'Pending',
          };

          await FirebaseFirestore.instance
              .collection('appointments')
              .doc(appointmentId)
              .set(appointmentData);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Appointment booked successfully!')));

          Navigator.pop(context); // Go back after booking
        }
      } catch (e) {
        print('Error booking appointment: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to book appointment. Try again later.')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment with ${widget.doctorName}'),
        backgroundColor: Colors.teal[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Wrap the form with Form widget for validation
            child: Column(
              children: [
                // Doctor's Name (Read-only)
                TextFormField(
                  initialValue: widget.doctorName,
                  decoration: InputDecoration(labelText: 'Doctor Name'),
                  readOnly: true,
                ),
                SizedBox(height: 10),

                // Phone Number (Required with Validation)
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    } else if (!RegExp(phonePattern).hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Date Picker for Appointment Date
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    _selectedDate == null
                        ? 'Select Appointment Date'
                        : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                if (_selectedDate == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select a date',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 10),

                // Time Slot Picker (Required)
                Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  height: 70, // Set the height for the dropdown
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Time Slot',
                      border: OutlineInputBorder(),
                    ),
                    value: _slotTime.isEmpty ? null : _slotTime, // Set initial value
                    items: _timeSlots.map((String slot) {
                      return DropdownMenuItem<String>(
                        value: slot,
                        child: Text(slot),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _slotTime = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a time slot';
                      }
                      return null;
                    },
                    isExpanded: true,
                  ),
                ),
                SizedBox(height: 10),

                // Description (Optional/Updatable)
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                // Submit Button
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _bookAppointment,
                  child: Text('Book Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
