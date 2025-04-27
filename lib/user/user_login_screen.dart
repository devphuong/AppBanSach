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

  Future<Map<String, dynamic>?>? _checkUserExistsFuture;

  @override
  void initState() {
    super.initState();
    retrieveUserCredentialsFromSharedPreferences();
  }

  Future<void> retrieveUserCredentialsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    print(
        'Email from UserLoginScreen: $email, Password from UserLoginScreen: $password');

    if (email != null && password != null) {
      setState(() {
        emailController.text = email;
        passwordController.text = password;
        _checkUserExistsFuture =
            checkUserExists(email: email, password: password);
      });
    }
  }

  Future<Map<String, dynamic>?> checkUserExists({
    required String email,
    required String password,
  }) async {
    print('Email checkUserExists: $email, Password checkUserExists: $password');

    var body = json.encode({'email': email, 'password': password});

    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.171:8000/api/auth/users'),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true) {
          print('Data checkUserExists: $data');
          var userData = data['data'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userData['id']);
          await prefs.setString('userName', userData['name']);
          await prefs.setString('userEmail', userData['email']);
          await prefs.setString('userPhone', userData['phone']);
          await prefs.setString('userAvatar', userData['avatar']);
          await prefs.setString(
              'userEmailVerifiedAt', userData['email_verified_at']);
          await prefs.setInt('userStatus', userData['role_id']);
          await prefs.setString('userCreatedAt', userData['created_at']);
          await prefs.setString('userUpdatedAt', userData['updated_at']);

          return data;
        } else {
          print('User does not exist or password is incorrect');
        }
      } else {
        print('Error checkUserExists: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error checking user existence: $e');
    }
    return null;
  }

  Widget _buildAvatarAndUsername() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _checkUserExistsFuture,
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return Text('Error Screen: ${snapshot.error}');
          } else {
            Map<String, dynamic>? user = snapshot.data;
            bool userExists = user != null && user['status'] == true;
            if (userExists) {
              String email = user['data']['email'] ?? 'Tên người dùng';
              String username = user['data']['name'] ?? 'Tên người dùng';
              String? avatarUrl = user['data']['avatar'];
              print('http://192.168.1.171:8000/storage/$avatarUrl');
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(
                        'http://192.168.1.171:8000/storage/$avatarUrl',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      username,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      email,
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
              return Text('Người dùng không tồn tại hoặc sai mật khẩu');
            }
          }
        }
      },
    );
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
              _buildAvatarAndUsername(),
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
}
