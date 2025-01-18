import 'package:flutter/material.dart';


class SpecialityPage extends StatelessWidget {
  final List<Map<String, dynamic>> specialities = [
    {'name': 'Dentist', 'icon': Icons.coronavirus, 'specialists': 0},
    {'name': 'Cardiologist', 'icon': Icons.favorite, 'specialists': 0},
    {'name': 'Dermatologist', 'icon': Icons.face, 'specialists': 0},
    {'name': 'Ayurveda', 'icon': Icons.spa, 'specialists': 0},
    {'name': 'Eye Care', 'icon': Icons.remove_red_eye, 'specialists': 0},
    {'name': 'Orthopedic', 'icon': Icons.elderly, 'specialists': 0},
    {'name': 'Urologist', 'icon': Icons.water_drop, 'specialists': 0},
    {'name': 'Gynecologist', 'icon': Icons.pregnant_woman, 'specialists': 0},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Speciality'),
        backgroundColor: Colors.teal,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: specialities.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  specialities[index]['icon'],
                  size: 40,
                  color: Colors.redAccent,
                ),
                SizedBox(height: 8),
                Text(
                  specialities[index]['name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${specialities[index]['specialists']} specialist',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

