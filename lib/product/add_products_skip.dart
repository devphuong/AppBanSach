// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:tot_nghiep_ban_sach_thu_vien/common/DialogHelper.dart';
// import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_form_button.dart';
// import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_input_field.dart';
// import 'package:tot_nghiep_ban_sach_thu_vien/common/page_heading.dart';
// import 'package:tot_nghiep_ban_sach_thu_vien/currency_handling/currency_handling.dart';
// import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';
// import 'package:tot_nghiep_ban_sach_thu_vien/page_home/home_page.dart';
// import 'package:mime/mime.dart';

// class AddproductPage extends StatefulWidget {
//   const AddproductPage({Key? key}) : super(key: key);

//   @override
//   State<AddproductPage> createState() => _AddproductPageState();
// }

// class User {
//   final String email;
//   final String password;

//   User({required this.email, required this.password});
// }

// class _AddproductPageState extends State<AddproductPage> {
//   final _signupFormKey = GlobalKey<FormState>();

//   Future _pickProfileImage() async {
//     try {
//       final image = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (image == null) return;

//       final imageTemporary = File(image.path);
//       setState(() => _selectedImage = imageTemporary);
//     } on PlatformException catch (e) {
//       debugPrint('Failed to pick image error: $e');
//     }
//   }

//   Future<void> _pickProfileImagealbum() async {
//     try {
//       final pickedImages = await ImagePicker().pickMultiImage();
//       if (pickedImages == null || pickedImages.isEmpty) return;

//       setState(() {
//         _selectedAlbumImages.addAll(
//           pickedImages.map((pickedImage) => File(pickedImage.path)).toList(),
//         );
//       });
//     } on PlatformException catch (e) {
//       debugPrint('Failed to pick image error: $e');
//     }
//   }

//   Future<bool> _authenticateUser(User user) async {
//     final Map<String, dynamic>? userData = await checkUserExists(
//       email: user.email,
//       password: user.password,
//     );

//     return userData != null;
//   }

//   Future<Map<String, dynamic>?> checkUserExists({
//     required String email,
//     required String password,
//   }) async {
//     var body = json.encode({'email': email, 'password': password});

//     var response = await http.post(
//       Uri.parse('http://192.168.2.9:8000/api/auth/users'),
//       body: body,
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//     ).timeout(const Duration(seconds: 5));

//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = json.decode(response.body);
//       print('Data: $data');
//       return data;
//     } else {
//       print('ERROR!');
//       return null;
//     }
//   }

//   String _email = ''; //ERRO
//   String _password = ''; //ERRO
//   bool _isSelectingProfileImage = true;
//   File? _selectedImage;
//   TextEditingController _productnameController = TextEditingController();
//   TextEditingController _categoryController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();
//   TextEditingController _shortDescriptionController = TextEditingController();
//   TextEditingController _promotionalPriceController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xffEEF1F3),
//         body: SingleChildScrollView(
//           child: Form(
//             key: _signupFormKey,
//             child: Column(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       const PageHeading(
//                         title: 'Thêm sản phẩm',
//                       ),
//                       SizedBox(
//                         width: 350,
//                         height: 200,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'THÊM ẢNH ĐẠI DIỆN',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             SizedBox(
//                               width: 130,
//                               height: 130,
//                               child: Stack(
//                                 children: [
//                                   Container(
//                                     width: 130,
//                                     height: 130,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade200,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: _selectedImage != null
//                                         ? Image.file(
//                                             _selectedImage!,
//                                             width: 130,
//                                             height: 130,
//                                             fit: BoxFit.cover,
//                                           )
//                                         : null,
//                                   ),
//                                   Positioned(
//                                     bottom: 5,
//                                     right: 5,
//                                     child: GestureDetector(
//                                       onTap: _pickProfileImage,
//                                       child: Container(
//                                         height: 50,
//                                         width: 50,
//                                         decoration: BoxDecoration(
//                                           color: Colors.blue.shade400,
//                                           border: Border.all(
//                                               color: Colors.white, width: 3),
//                                           borderRadius:
//                                               BorderRadius.circular(25),
//                                         ),
//                                         child: const Icon(
//                                           Icons.camera_alt_sharp,
//                                           color: Colors.white,
//                                           size: 25,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       SizedBox(
//                         width: 350,
//                         height: 200,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   'ALBUM ẢNH',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       _isSelectingProfileImage = false;
//                                     });
//                                     _pickProfileImagealbum();
//                                   },
//                                   child: Container(
//                                     margin: EdgeInsets.only(left: 8.0),
//                                     height: 30,
//                                     width: 30,
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue.shade400,
//                                       border: Border.all(
//                                           color: Colors.white, width: 2),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.camera_alt_sharp,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 10),
//                             Container(
//                               height: 100,
//                               child: Scrollbar(
//                                 thickness: 8.0,
//                                 radius: Radius.circular(4.0),
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: Row(
//                                     children: _buildAlbumsWidgets(),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomInputField(
//                         labelText: 'Tên Sản Phẩm',
//                         hintText: 'Nhập Tên Sản Phẩm...',
//                         isDense: true,
//                         controller: _productnameController,
//                         validator: (textValue) {
//                           if (textValue == null || textValue.isEmpty) {
//                             return 'Name field is required!';
//                           }
//                           return null;
//                         },
//                         keyboardType: TextInputType.text,
//                         inputFormatters: [],
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomInputField(
//                         labelText: 'Danh Mục',
//                         hintText: 'Nhập Danh Mục...',
//                         isDense: true,
//                         controller: _categoryController,
//                         validator: (textValue) {
//                           if (textValue == null || textValue.isEmpty) {
//                             return 'Category field is required!';
//                           }
//                           return null;
//                         },
//                         keyboardType: TextInputType.text,
//                         inputFormatters: [],
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomInputField(
//                         labelText: 'Mô Tả',
//                         hintText: 'Nhập mô tả sản phẩm',
//                         isDense: true,
//                         controller: _descriptionController,
//                         validator: (textValue) {
//                           if (textValue == null || textValue.isEmpty) {
//                             return 'Mô tả sản phẩm là bắt buộc!';
//                           }
//                           return null;
//                         },
//                         keyboardType: TextInputType.text,
//                         inputFormatters: [],
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomInputField(
//                         labelText: 'Mô Tả Ngắn',
//                         hintText: 'Nhập mô tả ngắn sản phẩm',
//                         isDense: true,
//                         controller: _shortDescriptionController,
//                         validator: (textValue) {
//                           if (textValue == null || textValue.isEmpty) {
//                             return 'Mô tả ngắn sản phẩm là bắt buộc!';
//                           }
//                           return null;
//                         },
//                         keyboardType: TextInputType.text,
//                         inputFormatters: [],
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomInputField(
//                         labelText: 'Giá Sản Phẩm',
//                         hintText: 'Nhập giá sản phẩm',
//                         isDense: true,
//                         controller: _priceController,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           CurrencyInputFormatter(),
//                         ],
//                         validator: (textValue) {
//                           if (textValue == null || textValue.isEmpty) {
//                             return 'Giá sản phẩm là bắt buộc!';
//                           }
//                           return null;
//                         },
//                         keyboardType: TextInputType.number,
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomInputField(
//                         labelText: 'Giá Khuyến Mãi',
//                         hintText: 'Nhập giá khuyến mãi',
//                         isDense: true,
//                         controller: _promotionalPriceController,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           CurrencyInputFormatter(),
//                         ],
//                         validator: (textValue) {
//                           if (textValue == null || textValue.isEmpty) {
//                             return 'Giá khuyến mãi là bắt buộc!';
//                           }
//                           return null;
//                         },
//                         keyboardType: TextInputType.number,
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       CustomFormButton(
//                         innerText: 'Đăng',
//                         onPressed: () {
//                           _handleAddProducts(context,
//                               User(email: _email, password: _password));
//                         },
//                       ),
//                       const SizedBox(
//                         height: 18,
//                       ),
//                       SizedBox(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const Text(
//                               'Already have an account ? ',
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   color: Color(0xff939393),
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             GestureDetector(
//                               onTap: () => {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             const LoginScreen()))
//                               },
//                               child: const Text(
//                                 'Log-in',
//                                 style: TextStyle(
//                                     fontSize: 15,
//                                     color: Color(0xff748288),
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 30,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleAddProducts(BuildContext context, User user) async {
//     final bool isUserAuthenticated = await _authenticateUser(user);
//     if (!isUserAuthenticated) {
//       return;
//     }

//     if (_signupFormKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Đang gửi dữ liệu..')),
//       );

//       try {
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('http://192.168.2.9:8000/api/addproduct'),
//         );

//         request.fields['product_name'] = _productnameController.text;
//         request.fields['category'] = _categoryController.text;
//         request.fields['detailed_description'] = _descriptionController.text;
//         request.fields['short_description'] = _shortDescriptionController.text;
//         request.fields['price'] = _priceController.text;
//         request.fields['promotional_price'] = _promotionalPriceController.text;

//         if (_selectedImage != null) {
//           print('Selected Image: ${_selectedImage!.path}');
//           var mimeType = lookupMimeType(_selectedImage!.path);
//           if (mimeType != null) {
//             request.files.add(
//               await http.MultipartFile.fromPath(
//                 'imgproduct',
//                 _selectedImage!.path,
//                 contentType: MediaType.parse(mimeType),
//               ),
//             );
//           } else {
//             _showDialog('Lỗi định dạng ảnh', 'Hãy chọn một hình ảnh khác!');
//             return;
//           }
//         }

//         for (var imagealbums in _selectedAlbumImages) {
//           print('Selected Album Image: ${imagealbums.path}');
//           var mimeType = lookupMimeType(imagealbums.path);
//           if (mimeType != null) {
//             request.files.add(
//               await http.MultipartFile.fromPath(
//                 'album',
//                 imagealbums.path,
//                 contentType: MediaType.parse(mimeType),
//               ),
//             );
//           } else {
//             _showDialog('Lỗi định dạng ảnh', 'Hãy chọn một hình ảnh khác!');
//             return;
//           }
//         }

//         var response = await request.send().timeout(Duration(seconds: 10));

//         if (response.statusCode == 201) {
//           DialogHelper.showAlertDialog(
//             context,
//             'Thành công',
//             'Sản phẩm đã được thêm thành công!',
//             () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => HomeScreen()),
//               );
//             },
//           );
//         } else {
//           DialogHelper.showAlertDialog(
//             context,
//             'Lỗi',
//             'Có lỗi xảy ra. Vui lòng thử lại sau!',
//             () {},
//           );
//           print('Lỗi: StatusCode ${response.statusCode}');
//         }
//       } catch (e) {
//         print('Lỗi: $e');
//         if (e is TimeoutException) {
//           DialogHelper.showAlertDialog(
//             context,
//             'Lỗi máy chủ',
//             'Quá thời gian kết nối. Vui lòng thử lại sau!',
//             () {},
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lỗi: $e')),
//           );
//         }
//       }
//     }
//   }

//   void _showDialog(String title, String content) {
//     DialogHelper.showAlertDialog(context, title, content);
//   }

//   List<File> _selectedAlbumImages = [];
//   List<Widget> _buildAlbumsWidgets() {
//     return _selectedAlbumImages.map((image) {
//       return Padding(
//         padding: EdgeInsets.only(right: 10),
//         child: GestureDetector(
//           onTap: () {
//             print('Selected image: ${image.path}');
//           },
//           child: Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               color: Colors.grey.shade200,
//               image: DecorationImage(
//                 image: FileImage(image),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }
// }
