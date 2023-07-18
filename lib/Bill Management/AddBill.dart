import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Bill%20Management/BillManagement.dart';
import 'package:trytest/Bill%20Management/BillModel.dart';

class AddBill extends StatefulWidget {
  const AddBill({Key? key}) : super(key: key);

  @override
  State<AddBill> createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> {
  final TextEditingController accountAddressController = TextEditingController();
  final TextEditingController accountCurrentMeterReadingController = TextEditingController();
  final TextEditingController accountNewMeterReadingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bill'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getMyField(
              focusNode: focusNode,
              hintText: 'Account Address',
              keyboardType: TextInputType.text,
              controller: accountAddressController,
            ),
            getMyField(
              hintText: 'Account Current Meter Reading',
              keyboardType: TextInputType.number,
              controller: accountCurrentMeterReadingController,
            ),
            getMyField(
              hintText: 'Account New Meter Reading',
              keyboardType: TextInputType.number,
              controller: accountNewMeterReadingController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Bill bill = Bill(
                      accountAddress: accountAddressController.text,
                      accountCurrentMeterReading: accountCurrentMeterReadingController.text,
                      accountNewMeterReading: accountNewMeterReadingController.text,
                    );
                    addBill(bill, context);
                    
                  },
                  child: const Text('Add Bill'),
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

  void addBill(Bill bill, BuildContext context) {
    final billRef = FirebaseFirestore.instance.collection('Bill').doc();
    bill.accountId = billRef.id;
    final data = bill.toJson();
    billRef.set(data).whenComplete(() {
      if (kDebugMode) {
        print('Bill inserted.');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BillManagement()),
      );
    });
  }

  Widget getMyField({
    required String hintText,
    required TextInputType keyboardType,
    required TextEditingController controller,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: 'Enter $hintText',
          labelText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}
