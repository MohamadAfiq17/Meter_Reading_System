import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Staff%20Management/StaffManagement.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({Key? key}) : super(key: key);

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getMyField(
              focusNode: focusNode,
              hintText: 'Name',
              keyboardType: TextInputType.name,
              controller: nameController,
            ),
            getMyField(
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
            ),
            getMyField(
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              controller: phoneController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Staff staff = Staff(
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );
                    addStaff(staff, context);
                  },
                  child: const Text('Add Staff'),
                ),
                ElevatedButton(
                  onPressed: () {
                    nameController.text = '';
                    emailController.text = '';
                    phoneController.text = '';
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

  void addStaff(Staff staff, BuildContext context) {
    final staffRef = FirebaseFirestore.instance.collection('Staffs').doc();
    staff.id = staffRef.id;
    final data = staff.toJson();
    staffRef.set(data).whenComplete(() {
      if (kDebugMode) {
        print('Staff inserted.');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StaffManagement()),
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