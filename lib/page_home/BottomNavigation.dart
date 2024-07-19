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
    return FutureBuilder<Map<String, dynamic>?>(
      future: checkUserExists(email: email, password: password),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return Icon(Icons.error, color: Colors.red);
          } else {
            Map<String, dynamic>? user = snapshot.data;
            bool userExists = user != null;
            if (userExists) {
              var statusData = user['data'];
              var status = statusData['role_id'];
              if (status is int) {
                print('Status find: $status');
                return status == 1
                    ? PopupMenuButton<int>(
                        icon: Icon(Icons.add, color: Color(0xFF676E79)),
                        onSelected: (value) {
                          if (value == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddproductPage(),
                              ),
                            );
                          } else if (value == 2) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImportExcelGgSheetPage(),
                              ),
                            );
                          } else if (value == 3) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatisticsPage(),
                              ),
                            );
                          } else if (value == 4) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductPage(),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
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
                      )
                    : GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.shopping_basket,
                            color: Color(0xFF676E79)),
                      );
              } else {
                return SizedBox();
              }
            } else {
              return SizedBox();
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
    print('Email: $email, Password: $password');
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

        if (data['status'] == true) {
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
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking user existence: $e');
    }
    return null;
  }
}
