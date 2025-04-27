import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProfileScreen extends StatefulWidget {
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<Map<String, dynamic>?>? _userFuture;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = _retrieveUserData();
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

  Future<Map<String, dynamic>?> _retrieveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    String? username = prefs.getString('userName');
    String? avatarUrl = prefs.getString('userAvatar');
    int? roleId = prefs.getInt('userStatus');
    return {
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'roleId': roleId,
    };
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    bool isAdmin = userData['roleId'] == 1;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(
                  'http://192.168.1.171:8000/storage/${userData['avatarUrl']}',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['username'] ?? 'Tên người dùng',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      userData['email'] ?? 'Email người dùng',
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      isAdmin ? 'Admin' : 'Thành viên',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text('Có lỗi xảy ra.',
                    style: TextStyle(color: Colors.black)),
              );
            } else {
              Map<String, dynamic> userData = snapshot.data!;
              return Column(
                children: [
                  _buildProfileHeader(userData),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: [
                        _buildSettingsContainer(),
                        SizedBox(height: 20),
                        _buildPurchaseContainer(),
                        SizedBox(height: 20),
                        _buildUtilitiesContainer(),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettingsContainer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildProfileOption(
                'Chỉnh sửa thông tin',
                Icons.edit,
                () {},
                color: Colors.black,
              ),
              _buildProfileOption(
                'Lịch sử giao dịch',
                Icons.history,
                () {},
                color: Colors.black,
              ),
              _buildProfileOption(
                'Cài đặt tài khoản',
                Icons.settings,
                () {},
                color: Colors.black,
              ),
              _buildProfileOption(
                'Đăng xuất',
                Icons.logout,
                () {},
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseContainer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đơn mua',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildProfileOption(
                'Chờ xác nhận',
                Icons.pending,
                () {},
                color: Colors.black,
              ),
              _buildProfileOption(
                'Chờ lấy hàng',
                Icons.local_shipping,
                () {},
                color: Colors.black,
              ),
              _buildProfileOption(
                'Chờ giao hàng',
                Icons.delivery_dining,
                () {},
                color: Colors.black,
              ),
              _buildProfileOption(
                'Đánh giá',
                Icons.rate_review,
                () {},
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilitiesContainer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiện ích của tôi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildProfileOption(
                'Kho voucher',
                Icons.card_giftcard,
                () {},
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap,
      {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}
