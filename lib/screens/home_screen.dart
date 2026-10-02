import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../model/app_user.dart';
import 'display_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatelessWidget {
  final String uid;
  const HomeScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthController.userStream(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // ไม่พบเอกสารใน users -> ถือเป็น operator (สิทธิ์ต่ำสุด)
        final user = snap.data ??
            AppUser(uid: uid, name: '-', email: '-', role: 'operator');

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('EcoCarbon (${user.isAdmin ? 'Admin' : 'Operator'})'),
              actions: [
                IconButton(
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout),
                  onPressed: AuthController.signOut,
                ),
              ],
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.edit_note), text: 'บันทึกการปล่อยคาร์บอน'),
                Tab(icon: Icon(Icons.list_alt), text: 'รายการ'),
              ]),
            ),
            body: TabBarView(children: [
              const FormScreen(),
              DisplayScreen(user: user),
            ]),
          ),
        );
      },
    );
  }
}
