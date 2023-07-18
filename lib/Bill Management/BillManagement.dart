import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Bill%20Management/AddBill.dart';
import 'package:trytest/Bill%20Management/BillModel.dart';
import 'package:trytest/Bill%20Management/UpdateBill.dart';

class BillManagement extends StatelessWidget {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('Bill');

  BillManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Management'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _reference.get(),
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
            List<Bill> bill = querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Bill(
                accountId: doc.id,
                accountAddress: data['Account_Address'],
                accountCurrentMeterReading: data['Account_CurrentMeterReading'],
                accountNewMeterReading: data['Account_NewMeterReading'],
              );
            }).toList();
            return _getBody(bill);
          } else {
            return const Center(
              child: Text('No Bill'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBill()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getBody(List<Bill> bill) {
    return bill.isEmpty
        ? const Center(
            child: Text(
              'No Bill',
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            itemCount: bill.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(bill[index].accountAddress),
                leading: const CircleAvatar(
                  radius: 25,
                  //child: ,
                ),
                trailing: SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      InkWell(
                        child: const Icon(Icons.edit),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateBill(
                                bill: bill[index],
                              ),
                            ),
                          );
                        },
                      ),
                      InkWell(
                        child: const Icon(Icons.delete),
                        onTap: () {
                          _reference.doc(bill[index].accountId).delete();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillManagement(),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
