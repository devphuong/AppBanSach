import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/BooksPage/books_online_page.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/BooksPage/bookspage.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/StatisticsPage/statistics_page.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/file%20excel/import_gg_sheet_excel_page.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/product/add_products.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/product/product_page.dart';

class CookingNavigator extends StatefulWidget {
  const CookingNavigator({Key? key}) : super(key: key);

  @override
  State<CookingNavigator> createState() => _CookingNavigatorState();
}

class _CookingNavigatorState extends State<CookingNavigator> {
  @override
  void initState() {
    super.initState();
    _loadRoleId();
  }

  void _loadRoleId() async {
    int? savedRoleId = await getSavedRoleId();
    if (savedRoleId != null) {
      print('Lấy role_id từ SharedPreferences: $savedRoleId');
      // Xử lý logic dựa trên role_id
    } else {
      print('Không tìm thấy role_id đã lưu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.transparent,
      elevation: 9.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0)),
            color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width / 2 - 20.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  PopupMenuButton<String>(
                    icon: Icon(Icons.menu_book, color: Colors.red[700]),
                    onSelected: (String value) {
                      if (value == 'Sách Online Của Bạn') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BooksOnlinePage()),
                        );
                      } else if (value == 'Mua Hàng') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => BooksPage()),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Sách Online Của Bạn', 'Mua Hàng'}
                          .map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                  Icon(Icons.person_outline, color: Color(0xFF676E79)),
                ],
              ),
            ),
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width / 2 - 20.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child:
                        Icon(Icons.favorite_border, color: Color(0xFF676E79)),
                  ),
                  _buildUserIcon(
                    users: [
                      {
                        'email': emailController.text,
                        'password': passwordController.text
                      },
                    ],
                    email: emailController.text,
                    password: passwordController.text,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIcon({
    required List<Map<String, dynamic>> users,
    required String email,
    required String password,
  }) {
    return FutureBuilder<int?>(
      future: getSavedRoleId(),
      builder: (BuildContext context, AsyncSnapshot<int?> savedRoleSnapshot) {
        if (savedRoleSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (savedRoleSnapshot.hasError) {
          return Icon(Icons.error, color: Colors.red);
        } else {
          int? savedRoleId = savedRoleSnapshot.data;

          if (savedRoleId != null) {
            // Nếu đã lưu role_id, sử dụng role_id này
            print('role_id từ SharedPreferences: $savedRoleId');
            return _buildRoleBasedIcon(context, savedRoleId);
          } else {
            // Nếu chưa lưu role_id, gọi API checkUserExists
            return FutureBuilder<Map<String, dynamic>?>(
              future: checkUserExists(email: email, password: password),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, color: Colors.red);
                } else {
                  Map<String, dynamic>? user = snapshot.data;
                  if (user != null) {
                    var statusData = user['data'];
                    var status = statusData['role_id'];
                    if (status is int) {
                      print('role_id từ API: $status');
                      return _buildRoleBasedIcon(context, status);
                    }
                  }
                  // Nếu không tìm thấy user hoặc role_id
                  print('Đây là tài khoản khách');
                  return GestureDetector(
                    onTap: () {},
                    child:
                        Icon(Icons.shopping_basket, color: Color(0xFF676E79)),
                  );
                }
              },
            );
          }
        }
      },
    );
  }

  Widget _buildRoleBasedIcon(BuildContext context, int roleId) {
    if (roleId == 1) {
      return PopupMenuButton<int>(
        icon: Icon(Icons.add, color: Color(0xFF676E79)),
        onSelected: (value) {
          if (value == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AddproductPage()),
            );
          } else if (value == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ImportExcelGgSheetPage()),
            );
          } else if (value == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StatisticsPage()),
            );
          } else if (value == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProductPage()),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
          PopupMenuItem<int>(
            value: 1,
            child: Text('Thêm sản phẩm'),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Text('Import file Excel'),
          ),
          PopupMenuItem<int>(
            value: 3,
            child: Text('Thống Kê Doang Thu'),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () {},
        child: Icon(Icons.shopping_basket, color: Color(0xFF676E79)),
      );
    }
  }

  Future<Map<String, dynamic>?> checkUserExists({
    required String email,
    required String password,
  }) async {
    print('Email: $email, Password: $password');
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
          print('Data: $data');
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
          // Lưu role_id
          await prefs.setInt('roleId',
              userData['role_id']); // Lưu role_id vào SharedPreferences

          return data;
        } else {
          print('User does not exist or password is incorrect');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking user existence: $e');
    }
    return null;
  }

  Future<int?> getSavedRoleId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('roleId'); // Lấy giá trị role_id từ SharedPreferences
  }
}
