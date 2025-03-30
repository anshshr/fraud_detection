import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function()? onProfileTap;

  const CustomAppBar({Key? key, this.onProfileTap}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Ensure user can pick a new account

    if (mounted) {
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SplashScreen(),
      //   ), // Redirect to login
      //   (route) => false, // Clear navigation stack
      // );
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Profile Options",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "What would you like to do?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            Tooltip(
              message: 'Logout',
              child: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _logout();
                },
                icon: Icon(LucideIcons.logOut, color: Colors.red),
              ),
            ),
            Tooltip(
              message: 'Dashboard',
              child: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DashboardScreen(),
                  //   ),
                  // );
                },
                icon: Icon(LucideIcons.layoutDashboard, color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Icon(Icons.shield, color: Colors.white, size: 30),
          ),
          Text(
            "FraudShield",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(width: 16),
        GestureDetector(
          onTap: widget.onProfileTap ?? _showProfileDialog,
          child:
              firebaseUser?.photoURL != null
                  ? CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(firebaseUser!.photoURL!),
                  )
                  : CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 14,
                    backgroundImage: NetworkImage(
                      "https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg",
                    ),
                  ),
        ),
        SizedBox(width: 16),

        // Icon(Icons.menu, color: Colors.white),
      ],
    );
  }
}
