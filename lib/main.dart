import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/home_page.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ThuVienApp());
}

class ThuVienApp extends StatelessWidget {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThuVienApp',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: _getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return HomeScreen();
          }
        },
      ),
    );
  }
}
