import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/DialogHelper.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_form_button_login.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_input_field.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/page_header.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/page_heading.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/forget_password_page.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/signup_page.dart';
import 'dart:convert';

import 'page_home/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
bool _showErrors = true;

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    emailController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(
                          title: 'Log-in',
                        ),
                        CustomInputField(
                          labelText: 'Email',
                          hintText: 'Your email id',
                          controller: emailController,
                          validator: (textValue) {
                            if (_showErrors &&
                                (textValue == null || textValue.isEmpty)) {
                              return 'Email is required!';
                            }
                            if (_showErrors &&
                                !EmailValidator.validate(textValue!)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          inputFormatters: [],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomInputField(
                          labelText: 'Password',
                          hintText: 'Your password',
                          obscureText: true,
                          suffixIcon: true,
                          controller: passwordController,
                          validator: (textValue) {
                            if (_showErrors &&
                                (textValue == null || textValue.isEmpty)) {
                              return 'Password is required!';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          inputFormatters: [],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: size.width * 0.80,
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPasswordPage()))
                            },
                            child: const Text(
                              'Forget password?',
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomFormButtonLogin(
                          onPressed: () async {
                            _handleLoginUser();
                            return null;
                          },
                          innerText: 'Login',
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account ? ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff939393),
                                    fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupPage()))
                                },
                                child: const Text(
                                  'Sign-up',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff748288),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginUser() async {
    getDeviceIP();
    String email = emailController.text;
    String password = passwordController.text;
    if (_loginFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );
      try {
        var response = await http.post(
          Uri.parse('http://192.168.30.244:8000/api/auth/login'),
          body: {'email': email, 'password': password},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var token = data['access_token'];
          print('Token: $token');
          print('Success');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('password', password);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          emailController.text = '';
          passwordController.text = '';
          setState(() {
            _showErrors = false;
          });
        }
      } catch (error) {
        if (error is TimeoutException) {
          print('Request timed out, treating as server error: $error');
          print(
              'Assuming server error with status code: 500 (Internal Server Error)');
          _showDialog('Lỗi máy chủ 500.', 'Vui lòng thử lại sau!');
        } else {
          print('Request timed out, treating as server error: $error');
          print('Assuming server error with status code: 404 (Not Found)');
          _showDialog('Máy chủ không hoạt động 404.', 'Vui lòng thử lại!');
        }
      }
    }
  }

  void _showDialog(String title, String content) {
    DialogHelper.showAlertDialog(context, title, content);
  }

  void getDeviceIP() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          print('IP Address: ${addr.address}');
        }
      }
    }
  }
}
