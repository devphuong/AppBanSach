import 'package:flutter/material.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ThuVienApp());
}

class ThuVienApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThuVienApp',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: 'Welcome',
      routes: {
        'Welcome': (context) => LoginScreen(),
      },
    );
  }
}
