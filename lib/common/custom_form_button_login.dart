import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/user/user_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomFormButtonLogin extends StatefulWidget {
  final Future<void> Function()? onPressed;

  const CustomFormButtonLogin({
    Key? key,
    required this.onPressed,
    required String innerText,
  }) : super(key: key);

  @override
  _CustomFormButtonLoginState createState() => _CustomFormButtonLoginState();
}

class _CustomFormButtonLoginState extends State<CustomFormButtonLogin> {
  @override
  void initState() {
    super.initState();
    // _initializeData();
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
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () async {
          String email = emailController.text;
          String password = passwordController.text;
          bool isValidAccount = await checkAccountValidity(email, password);
          if (isValidAccount) {
            BuildContext localContext = context;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Thông báo'),
                  content: Text('Bạn muốn lưu mật khẩu không?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _savePasswordAndNavigate(
                            localContext, email, password);
                      },
                      child: Text('OK'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _navigateToHomeScreen(
                            localContext, email, password);
                      },
                      child: Text('Cancel'),
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
                  title: Text('Thông báo'),
                  content: Text('Tài khoản không hợp lệ.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 20),
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

  Future<bool> checkAccountValidity(String email, String password) async {
    try {
      print('Email: $email, Password: $password');
      var response = await http.post(
        Uri.parse('http://192.168.30.244:8000/api/auth/login'),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        bool userExists = await checkUserExists(email, password);

        print('Bool User exists: $userExists');

        bool isValid = userExists;

        print('Kết quả kiểm tra tài khoản: $isValid');

        if (isValid) {
          var token = data['access_token'];
          print('Token: $token');
          await saveUserCredentialsToSharedPreferences(email, password, token);
        }

        return isValid;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
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

  Future<void> _savePasswordAndNavigate(
      BuildContext context, String email, String password) async {
    bool isValidAccount = await checkAccountValidity(email, password);

    if (isValidAccount) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      await saveUserCredentialsToSharedPreferences(email, password, token!);

      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');
      String? savedToken = prefs.getString('token');
      print('Email saveUserCredentialsToSharedPreferences : $savedEmail');
      print('Password saveUserCredentialsToSharedPreferences : $savedPassword');
      print('Token saveUserCredentialsToSharedPreferences : $savedToken');

      var response = await http.post(
        Uri.parse('http://192.168.30.244:8000/api/auth/login'),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var token = data['access_token'];

        print('Password saved!');
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserLoginScreen(),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }

  Future<void> _navigateToHomeScreen(
      BuildContext context, String email, String password) async {
    bool isValidAccount = await checkAccountValidity(email, password);

    if (isValidAccount) {
      var response = await http.post(
        Uri.parse('http://192.168.30.244:8000/api/auth/login'),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var token = data['access_token'];
        print('Token: $token');
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserLoginScreen(),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }
}
