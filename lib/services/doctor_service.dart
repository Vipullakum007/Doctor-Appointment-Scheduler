import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorService {
  final CollectionReference doctorCollection = FirebaseFirestore.instance.collection('doctors');

  Stream<List<Map<String, String>>> getDoctorsStream() {
    return doctorCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'name': doc['name'] as String,
          'specialty': doc['specialization'] as String,
        };
      }).toList();
    });
  }

  Future<List<Map<String, String>>> getDoctorsList() async {
    try {
      // Fetch the documents from the collection
      QuerySnapshot snapshot = await doctorCollection.get();

      // Convert the documents to a list of maps with String keys and values
      List<Map<String, String>> doctors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // print(data['specializations']);
        List<dynamic> specializations = data['specializations'] ?? [];

        // Get the first specialization, or an empty string if not available
        String firstSpecialization = specializations.isNotEmpty
            ? specializations[0].toString()
            : '';

        return {
          'doctor_id': data['uid']?.toString() ?? '' ,
          'name': data['name']?.toString() ?? '',
          'specialization': firstSpecialization,  // Only the first specialization
        };
      }).toList();

      return doctors;
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

}
