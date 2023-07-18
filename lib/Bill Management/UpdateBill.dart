import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Bill%20Management/BillManagement.dart';
import 'package:trytest/Bill%20Management/BillModel.dart';

class UpdateBill extends StatelessWidget {
  final TextEditingController accountAddressController = TextEditingController();
  final TextEditingController accountCurrentMeterReadingController = TextEditingController();
  final TextEditingController accountNewMeterReadingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final Bill bill;

  UpdateBill({Key? key, required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    accountAddressController.text = bill.accountAddress;
    accountCurrentMeterReadingController.text = bill.accountCurrentMeterReading;
    accountNewMeterReadingController.text = bill.accountNewMeterReading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Bill'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getMyField(
              focusNode: focusNode,
              hintText: 'Account Address',
              textInputType: TextInputType.text,
              controller: accountAddressController,
            ),
            getMyField(
              hintText: 'Account Current Meter Reading',
              textInputType: TextInputType.number,
              controller: accountCurrentMeterReadingController,
            ),
            getMyField(
              hintText: 'Account New Meter Reading',
              textInputType: TextInputType.number,
              controller: accountNewMeterReadingController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Bill updatedBill = Bill(
                      accountId: bill.accountId,
                      accountAddress: accountAddressController.text,
                      accountCurrentMeterReading: accountCurrentMeterReadingController.text,
                      accountNewMeterReading: accountNewMeterReadingController.text,
                    );
                    final CollectionReference collectionReference =
                        FirebaseFirestore.instance.collection('Bills');
                    collectionReference
                        .doc(updatedBill.accountId)
                        .update(updatedBill.toJson())
                        .whenComplete(() {
                      if (kDebugMode) {
                        print('Bill Updated');
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillManagement(),
                        ),
                      );
                    });
                  },
                  child: const Text('Update Bill'),
                ),
                ElevatedButton(
                  onPressed: () {
                    accountAddressController.text = '';
                    accountCurrentMeterReadingController.text = '';
                    accountNewMeterReadingController.text = '';
                    focusNode.requestFocus();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getMyField({
    required String hintText,
    TextInputType textInputType = TextInputType.text,
    required TextEditingController controller,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        focusNode: focusNode,
        keyboardType: textInputType,
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Enter $hintText',
          labelText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
