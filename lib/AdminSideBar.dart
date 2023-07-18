import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trytest/Bill%20Management/BillManagement.dart';
import 'package:trytest/LoginPage.dart';
import 'package:trytest/Staff%20Management/StaffManagement.dart';

class AdminSideBar extends StatelessWidget {
  const AdminSideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Mohamad Afiq'),
            accountEmail: const Text('2021843088'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://www.google.com/imgres?imgurl=https%3A%2F%2Fc4.wallpaperflare.com%2Fwallpaper%2F769%2F76%2F924%2F1920x1080-green-mountain-nature-1920x1080-wallpaper-preview.jpg&tbnid=Ij1foJd2erCRWM&vet=12ahUKEwjvvpDj-Yz-AhWdHEQIHTmqDh8QMygAegUIARDjAQ..i&imgrefurl=https%3A%2F%2Fwww.wallpaperflare.com%2F1920x1080-green-mountain-nature-wallpaper-uxtha&docid=0iI0lvplosy_HM&w=728&h=410&q=nature%20mountain%20background&hl=en&ved=2ahUKEwjvvpDj-Yz-AhWdHEQIHTmqDh8QMygAegUIARDjAQ',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://www.example.com/background-image.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification'),
            onTap: () => null,
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: const Center(
                  child: Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('File Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BillManagement()),
              );
            },
          ),
          ListTile(
              leading: const Icon(Icons.people_sharp),
              title: const Text('Staff Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffManagement()),
                );
              }
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
          ),
        ],
      ),
    );
  }
}
