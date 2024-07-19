import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/Bill/billdetailpage.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/Cart/cartpage.dart';
import 'package:url_launcher/url_launcher.dart';

class BillPage extends StatefulWidget {
  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  int? previousMaxId;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String category = '';
  String productName = '';
  String imgproduct = '';
  String album = '';
  String detailed_description = '';
  String shortDescription = '';
  double price = 0.0;
  double promotionalPrice = 0.0;
  String pdfFile = '';
  int quantityBill = 0;
  int quantity = 0;
  int selectedQuantity = 0;
  Timer? _countdownTimer;

  String? userName;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _loadDataFromSharedPreferences();
    _fetchUserInfo();
    _fullNameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneNumberController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      category = prefs.getString('category') ?? '';
      productName = prefs.getString('product_name') ?? '';
      detailed_description = prefs.getString('detailed_description') ?? '';
      shortDescription = prefs.getString('short_description') ?? '';
      price = prefs.getDouble('price') ?? 0.0;
      promotionalPrice = prefs.getDouble('promotional_price') ?? 0.0;
      pdfFile = prefs.getString('pdf_file') ?? '';
      quantity = prefs.getInt('quantity') ?? 0;
      quantityBill = prefs.getInt('quantity_bill') ?? 0;
      selectedQuantity = prefs.getInt('selectedQuantity') ?? 0;
    });
    print(
        '==========================Thông tin ở Hóa Đơn=================================');
    print('category từ page bill...: $category');
    print('productName từ page bill...: $productName');
    print('detailed_description từ bill...: $detailed_description');
    print('shortDescription từ page bill...: $shortDescription');
    print('price từ page bill...: $price');
    print('promotionalPrice từ page bill...: $promotionalPrice');
    print('pdfFile từ page bill...: $pdfFile');
    print('Số lượng kho...: $quantity');
    print('quantityBill từ page bill...: $quantityBill');
    print('selectedQuantity từ page bill...: $selectedQuantity');
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      userEmail = prefs.getString('userEmail');
      userPhone = prefs.getString('userPhone');
    });
  }

  Future<void> printUserInfo() async {
    Map<String, dynamic> userInfo = await getUserInfo();
    print('User Info: $userInfo');
    print(
        '==========================Thông tin tài khoản ở Hóa Đơn=================================');
    print('ID: ${userInfo['id']}');
    print('Name: ${userInfo['name']}');
    print('Email: ${userInfo['email']}');
    print('Phone: ${userInfo['phone']}');
    print('Avatar: ${userInfo['avatar']}');
    print('Email Verified At: ${userInfo['email_verified_at']}');
    print('Status: ${userInfo['status']}');
    print('Created At: ${userInfo['created_at']}');
    print('Updated At: ${userInfo['updated_at']}');
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('userId'),
      'name': prefs.getString('userName'),
      'email': prefs.getString('userEmail'),
      'phone': prefs.getString('userPhone'),
      'avatar': prefs.getString('userAvatar'),
      'email_verified_at': prefs.getString('userEmailVerifiedAt'),
      'status': prefs.getInt('userStatus'),
      'created_at': prefs.getString('userCreatedAt'),
      'updated_at': prefs.getString('userUpdatedAt'),
    };
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = calculateTotalAmount();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hóa Đơn Thanh Toán'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin người dùng:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                'Tên: ${userName ?? 'Chưa có thông tin'}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Email: ${userEmail ?? 'Chưa có thông tin'}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Số điện thoại: ${userPhone ?? 'Chưa có thông tin'}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Loại Sách: $category',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Tên Sách: $productName',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Mô tả ngắn: $shortDescription',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              if (promotionalPrice > 0)
                Text(
                  'Giá: ${currencyFormat.format(price)}',
                  style: TextStyle(
                      fontSize: 18.0, decoration: TextDecoration.lineThrough),
                ),
              Text(
                promotionalPrice > 0
                    ? 'Giá khuyến mãi: ${currencyFormat.format(promotionalPrice)}'
                    : 'Giá: ${currencyFormat.format(price)}',
                style: TextStyle(
                    fontSize: 18.0,
                    color: promotionalPrice > 0 ? Colors.red : Colors.red,
                    fontWeight: promotionalPrice > 0
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              SizedBox(height: 10.0),
              if (pdfFile != null && pdfFile!.isNotEmpty)
                Text(
                  'PDF File: Sau thanh toán, hãy qua lại trang Mua Hàng và kiểm tra thông báo của chúng tôi!',
                  style: TextStyle(fontSize: 18.0),
                ),
              SizedBox(height: 10.0),
              Text(
                'Số lượng sách: $quantityBill',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Tổng tiền: ${currencyFormat.format(totalAmount)}',
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Địa chỉ *'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(context);
                    },
                    child: Text('Thanh toán'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                    child: Text('Hủy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;

    if (promotionalPrice > 0) {
      totalAmount = promotionalPrice * quantityBill;
    } else if (price > 0) {
      totalAmount = price * quantityBill;
    }

    return totalAmount;
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận thanh toán'),
          content: Text('Bạn có muốn thanh toán không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startCountdown(context);
                _initiatePayment();
              },
              child: Text('Có'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Không'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiatePayment() async {
    const url = 'http://192.168.30.244:8000/api/momopayment';
    await launch(url);
  }

  void _startCountdown(BuildContext context) {
    int seconds = 40;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (_countdownTimer == null || !_countdownTimer!.isActive) {
              _countdownTimer =
                  Timer.periodic(Duration(seconds: 1), (Timer timer) {
                if (seconds > 0) {
                  if (mounted) {
                    setState(() {
                      seconds--;
                    });
                  }
                } else {
                  timer.cancel();
                  if (mounted) {
                    _fetchSignature().then((_) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BillDetailPage()),
                        );
                      }
                    }).catchError((error) {
                      print('Error fetching signature _startCountdown: $error');
                    });
                  }
                }
              });
            }

            return AlertDialog(
              title: Text('Đang xử lý thanh toán'),
              content: Text('Vui lòng đợi $seconds giây...'),
            );
          },
        );
      },
    );
  }

  Future<void> _fetchSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedMaxId = prefs.getInt('maxId');

    var url = Uri.parse('http://192.168.30.244:8000/api/all-momopayment');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var momosList = jsonResponse['data'] as List<dynamic>;

        if (momosList.isNotEmpty) {
          int maxId = momosList
              .map((momo) => momo['id'] as int)
              .reduce((a, b) => a > b ? a : b);

          if (savedMaxId != null && maxId == savedMaxId) {
            print(
                '=============================================== THỜI GIAN THANH TOÁN QUÁ HẠN BillPage! ===============================================');

            await prefs.setInt('statusbill', 1);
            return;
          }

          await prefs.setInt('maxId', maxId);
          var urlWithMaxId =
              Uri.parse('http://192.168.30.244:8000/api/momopayment/$maxId');

          var detailResponse = await http.get(urlWithMaxId);
          if (detailResponse.statusCode == 200) {
            var detailJsonResponse = jsonDecode(detailResponse.body);

            if (detailJsonResponse['status'] == true) {
              var momos = detailJsonResponse['momos'];
              if (momos != null) {
                String? signature = momos['signature'] as String?;
                int? resultCode = momos['resultCode'] as int?;

                if (signature != null && signature.isNotEmpty) {
                  await Future.wait([
                    _addToCartWithSignature(signature, resultCode),
                    _addToBill(signature, resultCode),
                  ]);
                } else {
                  print('Signature is null or empty');
                }
              } else {
                print('Momos object is null');
              }
            } else {
              print('Status is false in detail response');
            }
          } else {
            print(
                'Failed to fetch signature detail. Status code: ${detailResponse.statusCode}');
          }
        } else {
          print(
              '=============================================== THỜI GIAN THANH TOÁN QUÁ HẠN! ===============================================');
          await prefs.setInt('statusbill', 1);
        }
      } else {
        print(
            'Failed to fetch momos list. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching signature: $e');
    }
  }

  Future<void> _addToCartWithSignature(
      String signature, int? resultCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? category = prefs.getString('category');
    String? productName = prefs.getString('product_name');
    String? shortDescription = prefs.getString('short_description');
    double? price = prefs.getDouble('price');
    double? promotionalPrice = prefs.getDouble('promotional_price');
    String? pdfFile = prefs.getString('pdf_file');
    int? quantityBill = prefs.getInt('quantity_bill');
    String? fullName = userName;
    String? email = userEmail;
    String? phoneNumber = userPhone;
    String address = _addressController.text;

    String? finalPrice;
    String? finalPromotionalPrice;

    print('price ==> $price');
    print('promotionalPrice ==> $promotionalPrice');

    if (promotionalPrice != null && promotionalPrice > 0) {
      finalPrice = null;
      finalPromotionalPrice = promotionalPrice.toString();
    } else if (price != null && price > 0) {
      finalPrice = price.toString();
      finalPromotionalPrice = null;
    } else {
      finalPrice = null;
      finalPromotionalPrice = null;
    }

    double totalAmount = 0.0;
    if (promotionalPrice != null && promotionalPrice > 0) {
      totalAmount = promotionalPrice * (quantityBill ?? 1);
    } else if (price != null && price > 0) {
      totalAmount = price * (quantityBill ?? 1);
    }

    print('finalPrice ==> $finalPrice');
    print('finalPromotionalPrice ==> $finalPromotionalPrice');
    print('totalAmount ==> $totalAmount');

    var url = Uri.parse('http://192.168.30.244:8000/api/addcart');
    var body = {
      'category': category ?? '',
      'product_name': productName ?? '',
      'short_description': shortDescription ?? '',
      'price': finalPrice,
      'promotional_price': finalPromotionalPrice,
      'pdf_file': pdfFile ?? '',
      'quantity_bill': quantityBill?.toString() ?? '',
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'success': '0',
      'unsuccessful': '0',
      'approving': '1',
      'signature': signature,
      'resultCode': resultCode,
      'totalAmount': totalAmount
    };

    print('Sending request body to add to cart: $body');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print('Product added to cart successfully');
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setInt('statusbill', 0));
    } else {
      print(
          'Failed to add product to cart. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _addToBill(String signature, int? resultCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? category = prefs.getString('category');
    String? productName = prefs.getString('product_name');
    String? shortDescription = prefs.getString('short_description');
    double? price = prefs.getDouble('price');
    double? promotionalPrice = prefs.getDouble('promotional_price');
    String? pdfFile = prefs.getString('pdf_file');
    int? quantityBill = prefs.getInt('quantity_bill');
    String? fullName = userName;
    String? email = userEmail;
    String? phoneNumber = userPhone;
    String address = _addressController.text;

    String? finalPrice;
    String? finalPromotionalPrice;

    print('price ==> $price');
    print('promotionalPrice ==> $promotionalPrice');

    if (promotionalPrice != null && promotionalPrice > 0) {
      finalPrice = null;
      finalPromotionalPrice = promotionalPrice.toString();
    } else if (price != null && price > 0) {
      finalPrice = price.toString();
      finalPromotionalPrice = null;
    } else {
      finalPrice = null;
      finalPromotionalPrice = null;
    }

    double totalAmount = 0.0;
    if (promotionalPrice != null && promotionalPrice > 0) {
      totalAmount = promotionalPrice * (quantityBill ?? 1);
    } else if (price != null && price > 0) {
      totalAmount = price * (quantityBill ?? 1);
    }

    print('finalPrice ==> $finalPrice');
    print('finalPromotionalPrice ==> $finalPromotionalPrice');
    print('totalAmount ==> $totalAmount');

    var url = Uri.parse('http://192.168.30.244:8000/api/addbill');
    var body = {
      'category': category ?? '',
      'product_name': productName ?? '',
      'short_description': shortDescription ?? '',
      'price': finalPrice,
      'promotional_price': finalPromotionalPrice,
      'pdf_file': pdfFile ?? '',
      'quantity_bill': quantityBill?.toString() ?? '',
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'signature': signature,
      'resultCode': resultCode,
      'totalAmount': totalAmount,
    };

    print('Sending request body to add to bill: $body');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print('Product added to Bill successfully');
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setInt('statusbill', 0));
    } else {
      print(
          'Failed to add product to bill. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
