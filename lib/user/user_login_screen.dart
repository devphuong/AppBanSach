import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/home_page.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    retrieveUserCredentialsFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppbarTitle(),
              SizedBox(height: 20),
              _buildAvatarAndUsername(
                email: emailController.text,
                password: passwordController.text,
              ),
              SizedBox(height: 20),
              _buildLoginButton(),
              SizedBox(height: 10),
              _buildOtherAccountButton(),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: _buildCreateAccountButton(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'images/ic_launcher.png',
          width: 70,
          height: 70,
        ),
      ],
    );
  }

  Widget _buildAvatarAndUsername({
    required String email,
    required String password,
  }) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: checkUserExists(email: email, password: password),
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        print('Email from _buildAvatarAndUsername: $email');
        print('Password from _buildAvatarAndUsername: $password');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Map<String, dynamic>? user = snapshot.data;
            bool userExists = user != null;
            if (userExists) {
              String Email = user['data']['email'] ?? 'Tên người dùng';
              String username = user['data']['name'] ?? 'Tên người dùng';
              String? avatarUrl = user['data']['avatar'];
              print('http://192.168.30.244:8000/storage/$avatarUrl');
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(
                        'http://192.168.30.244:8000/storage/$avatarUrl',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      username,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      Email,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/default_avatar_path'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      username,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                );
              }
            } else {
              return Text('Người dùng không tồn tại');
            }
          }
        }
      },
    );
  }

  Future<Map<String, dynamic>?> checkUserExists({
    required String email,
    required String password,
  }) async {
    print('Email from checkUserExists: $email');
    print('Password from checkUserExists: $password');

    var body = json.encode({'email': email, 'password': password});

    try {
      var response = await http.post(
        Uri.parse('http://192.168.30.244:8000/api/auth/users'),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print('Data: $data');
        return data;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 0, 153, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Đăng nhập',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherAccountButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side:
                BorderSide(color: Color.fromARGB(255, 117, 117, 117), width: 1),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Đăng nhập bằng tài khoản khác',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Color.fromARGB(255, 0, 153, 255), width: 1),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Tạo tài khoản mới',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 0, 153, 255),
            ),
          ),
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
    print('Email from UserLoginScreen: $email');
    print('Password from UserLoginScreen: $password');

    if (email != null && password != null) {
      emailController.text = email;
      passwordController.text = password;

      setState(() {
        _buildAvatarAndUsername(
          email: email,
          password: password,
        );
      });
    }
  }
}
