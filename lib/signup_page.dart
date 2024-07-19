import 'dart:async';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/common/DialogHelper.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_form_button.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_input_field.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/page_header.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/page_heading.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _signupFormKey = GlobalKey<FormState>();

  Future _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _selectedImage = imageTemporary);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Form(
            key: _signupFormKey,
            child: Column(
              children: [
                const PageHeader(),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const PageHeading(
                        title: 'Sign-up',
                      ),
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: _pickProfileImage,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_sharp,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Name',
                        hintText: 'Your name',
                        isDense: true,
                        controller: _nameController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Name field is required!';
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
                        labelText: 'Email',
                        hintText: 'Your email id',
                        isDense: true,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Email is required!';
                          }
                          if (!EmailValidator.validate(textValue)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        inputFormatters: [],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Phone Number',
                        hintText: 'Your contact number',
                        isDense: true,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Contact number is required!';
                          }
                          return null;
                        },
                        inputFormatters: [],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Password',
                        hintText: 'Your password',
                        isDense: true,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Password is required!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        suffixIcon: true,
                        inputFormatters: [],
                      ),
                      const SizedBox(height: 22),
                      CustomInputField(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        isDense: true,
                        obscureText: true,
                        controller: _confirmPasswordController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Confirm Password is required!';
                          }
                          if (textValue != _passwordController.text) {
                            return 'Passwords do not match!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        suffixIcon: true,
                        inputFormatters: [],
                      ),
                      const SizedBox(height: 22),
                      CustomFormButton(
                        innerText: 'SignUp',
                        onPressed: _handleSignupUser,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account ? ',
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
                                            const LoginScreen()))
                              },
                              child: const Text(
                                'Log-in',
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
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignupUser() async {
    if (_signupFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.0.168:8000/api/auth/register'),
        );

        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        request.fields['phone'] = _phoneController.text;

        if (_selectedImage != null) {
          print('Selected Image SignupPage: ${_selectedImage!.path}');
          var mimeType = lookupMimeType(_selectedImage!.path);
          if (mimeType != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'avatar',
                _selectedImage!.path,
                contentType: MediaType.parse(mimeType),
              ),
            );
          } else {
            _showDialog('Lỗi định dạng ảnh', 'Hãy chọn một hình ảnh khác!');
            return;
          }
        }

        var response = await request.send().timeout(Duration(seconds: 10));

        if (response.statusCode == 201) {
          DialogHelper.showAlertDialog(
            context,
            'Đăng ký thành công',
            'Hãy đăng nhập ngay!',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          );
        } else {
          DialogHelper.showAlertDialog(
            context,
            'Đăng ký không thành công',
            'Hãy thử lại!',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
          );
        }
      } catch (e) {
        if (e is TimeoutException) {
          DialogHelper.showAlertDialog(
            context,
            'Lỗi máy chủ 500.',
            'Quá thời gian kết nối. Hãy thử lại sau!',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showDialog(String title, String content) {
    DialogHelper.showAlertDialog(context, title, content);
  }
}
