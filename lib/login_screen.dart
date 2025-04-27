import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/Language/languageswitchpage.dart';

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

  String title = 'Đăng nhập';
  String emailLabel = 'E-mail';
  String emailtxt = 'Email của bạn';
  String passwordLabel = 'Mật khẩu';
  String passwordtxt = 'Mật khẩu của bạn';
  String forgetPasswordText = 'Quên mật khẩu?';
  String signUpText = ' Đăng ký';
  String dontHaveAccountText = 'Không có tài khoản?';
  String buttonlogin = 'Đăng nhập';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String currentLanguage = prefs.getString('languageCode') ?? 'vi';
    print("Ngôn ngữ hiện tại trong trang Đăng Nhập: $currentLanguage");
    setState(() {
      if (currentLanguage == 'vi') {
        title = 'Đăng Nhập';
        emailLabel = 'Email';
        emailtxt = 'Nhập email của bạn';
        passwordLabel = 'Mật khẩu';
        passwordtxt = 'Nhập mật khẩu của bạn';
        forgetPasswordText = 'Quên mật khẩu?';
        signUpText = 'Đăng ký';
        dontHaveAccountText = 'Chưa có tài khoản?';
        buttonlogin = 'Đăng nhập';
      } else {
        title = 'Log-in';
        emailLabel = 'Email';
        emailtxt = 'Your Email';
        passwordLabel = 'Password';
        passwordtxt = 'Your Password';
        forgetPasswordText = 'Forget password?';
        signUpText = 'Sign-up';
        dontHaveAccountText = "Don't have an account ?";
        buttonlogin = 'Login';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.clear();
    passwordController.clear();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            Stack(
              children: [
                const PageHeader(),
                Positioned(
                    right: 16,
                    top: 16,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.settings),
                      onSelected: (value) async {
                        if (value == 'language') {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LanguageSwitchPage()),
                          );
                          if (result != null) {
                            setState(() {
                              title = result['title'];
                              emailLabel = result['email'];
                              emailtxt = result['emailtxt'];
                              passwordLabel = result['password'];
                              passwordtxt = result['passwordtxt'];
                              forgetPasswordText = result['forgetPassword'];
                              signUpText = result['signUp'];
                              dontHaveAccountText = result['dontHaveAccount'];
                              buttonlogin = result['buttonlogin'];
                            });
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'language',
                          child: Row(
                            children: const [
                              Icon(Icons.language, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Ngôn ngữ'),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
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
                        PageHeading(title: title),
                        CustomInputField(
                          labelText: emailLabel,
                          hintText: emailtxt,
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
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [],
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          labelText: passwordLabel,
                          hintText: passwordtxt,
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
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgetPasswordPage()))
                          },
                          child: Text(
                            forgetPasswordText,
                            style: const TextStyle(
                              color: Color(0xff939393),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomFormButtonLogin(
                          onPressed: () async {
                            return null;
                          },
                          innerText: buttonlogin,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dontHaveAccountText,
                              style: const TextStyle(
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
                              child: Text(
                                signUpText,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xff748288),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
          Uri.parse('http://192.168.1.171:8000/api/auth/login'),
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
