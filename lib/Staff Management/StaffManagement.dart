import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Staff%20Management/AddStaff.dart';
import 'package:trytest/Staff%20Management/UpdateStaff.dart';

class Staff {
  String? id;
  final String name;
  final String email;
  final String phone;

  Staff({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
      };
}

class StaffManagement extends StatelessWidget {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('Staffs');

  StaffManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reference.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong.'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data!;
            List<Staff> staff = querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Staff(
                id: doc.id,
                name: data['name'],
                email: data['email'],
                phone: data['phone'],
              );
            }).toList();
            return _getBody(staff);
          } else {
            return const Center(
              child: Text('No Staff'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStaff()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getBody(List<Staff> staff) {
    return staff.isEmpty
        ? const Center(
            child: Text(
              'No Staff',
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            itemCount: staff.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(staff[index].name),
                subtitle: Text('Email: ${staff[index].email}'),
                leading: const CircleAvatar(
                  radius: 25,
                  //child: ,
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: const Icon(Icons.edit),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateStaff(
                                staff: staff[index],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        child: const Icon(Icons.delete),
                        onTap: () {
                          _reference.doc(staff[index].id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
