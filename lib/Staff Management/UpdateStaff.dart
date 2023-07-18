import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Staff Management/StaffManagement.dart';

class UpdateStaff extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final Staff staff;

  UpdateStaff({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    nameController.text = staff.name;
    emailController.text = staff.email;
    phoneController.text = staff.phone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Staff'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getMyField(
              focusNode: focusNode,
              hintText: 'Name',
              textInputType: TextInputType.name,
              controller: nameController,
            ),
            getMyField(
              hintText: 'Email',
              textInputType: TextInputType.emailAddress,
              controller: emailController,
            ),
            getMyField(
              hintText: 'Phone Number',
              textInputType: TextInputType.phone,
              controller: phoneController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Staff updatedStaff = Staff(
                      id: staff.id,
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );
                    final CollectionReference collectionReference =
                        FirebaseFirestore.instance.collection('Staffs');
                    collectionReference
                        .doc(updatedStaff.id)
                        .update(updatedStaff.toJson())
                        .whenComplete(() {
                      if (kDebugMode) {
                        print('Staff Updated');
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffManagement(),
                        ),
                      );
                    });
                  },
                  child: const Text('Update Staff'),
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

  Widget getMyField({
    required String hintText,
    TextInputType textInputType = TextInputType.name,
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
