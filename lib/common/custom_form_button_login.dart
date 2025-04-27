import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/home_page.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/user/user_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomFormButtonLogin extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final String innerText;

  const CustomFormButtonLogin({
    Key? key,
    required this.onPressed,
    required this.innerText,
    // required String innerText,
  }) : super(key: key);

  @override
  _CustomFormButtonLoginState createState() => _CustomFormButtonLoginState();
}

class _CustomFormButtonLoginState extends State<CustomFormButtonLogin> {
  @override
  void initState() {
    super.initState();
    checkTokenAndNavigate(context);
  }

  Future<void> checkTokenAndNavigate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  Future<void> _initializeData() async {
    String? token = await retrieveTokenFromSharedPreferences();
    print('Token từ SharedPreferences: $token');
    await retrieveUserCredentialsFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () async {
          String email = emailController.text;
          String password = passwordController.text;

          var result = await checkAccountValidity(email, password);
          if (result['isValid']) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Bạn muốn lưu mật khẩu không?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _savePasswordAndNavigate(
                            context, email, password);
                      },
                      child: const Text('OK'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Tài khoản không hợp lệ.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Text(
          widget.innerText,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Future<void> saveUserCredentialsToSharedPreferences(
      String email, String password, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('token', token);
  }

  Future<void> retrieveUserCredentialsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    String? token = prefs.getString('token');
    print('Email from SharedPreferences: $email');
    print('Password from SharedPreferences: $password');
    print('Token from SharedPreferences: $token');
  }

  Future<String?> retrieveTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> checkAccountValidity(
      String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');

    if (savedToken != null) {
      return {'isValid': true, 'token': savedToken};
    }

    try {
      print('Email: $email, Password: $password');
      var response = await http.post(
        Uri.parse('http://192.168.1.171:8000/api/auth/login'),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        bool userExists = await checkUserExists(email, password);

        print('Bool User exists: $userExists');

        if (userExists) {
          var token = data['access_token'];
          print('Token: $token');
          await saveUserCredentialsToSharedPreferences(email, password, token);
          return {'isValid': true, 'token': token};
        } else {
          return {'isValid': false};
        }
      } else {
        print('Error: ${response.statusCode}');
        return {'isValid': false};
      }
    } catch (e) {
      print('Error: $e');
      return {'isValid': false};
    }
  }

  Future<void> _savePasswordAndNavigate(
      BuildContext context, String email, String password) async {
    var result = await checkAccountValidity(email, password);

    if (result['isValid']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      if (savedEmail != email || savedPassword != password) {
        String? savedToken = result['token'];

        await saveUserCredentialsToSharedPreferences(
            email, password, savedToken!);

        print('Password saved!');
        print('Email saved: $email');
        print('Password saved: $password');
        print('Token saved: $savedToken');

        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserLoginScreen(),
          ),
        );
      } else {
        print('Xin chào, $savedEmail!');

        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    }
  }

  Future<bool> checkUserExists(String email, String password) async {
    List<Map<String, dynamic>> users = [
      {'email': email, 'password': password},
    ];

    bool userExists = users.any(
      (user) => user['email'] == email && user['password'] == password,
    );

    print('User Email: $email, Password: $password, Exists: $userExists');

    return userExists;
  }
}
