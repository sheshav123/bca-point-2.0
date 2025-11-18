import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Database Content'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Categories:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(data['title'] ?? 'No title'),
                      subtitle: Text('ID: ${doc.id}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Subcategories:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('subcategories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.data!.docs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No subcategories found in database!'),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      title: Text(data['title'] ?? 'No title'),
                      subtitle: Text(
                        'ID: ${doc.id}\n'
                        'parentType: ${data['parentType'] ?? 'null'}\n'
                        'parentId: ${data['parentId'] ?? 'null'}\n'
                        'categoryId: ${data['categoryId'] ?? 'null'}\n'
                        'order: ${data['order']}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
