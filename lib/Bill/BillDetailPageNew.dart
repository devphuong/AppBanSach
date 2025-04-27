import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/home_page.dart';

class BillDetailPageNew extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? address;
  final String productName;
  final int quantityBill;
  final double totalAmount;

  BillDetailPageNew({
    Key? key,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.address,
    required this.productName,
    required this.quantityBill,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final String qrData =
        "Vietcombank\nTài khoản: 1016388651\nSố tiền: ${totalAmount.toStringAsFixed(0)}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => HomeScreen()),
        //     );
        //   },
        // ),
        title: Text(
          'Giỏ Hàng',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin Thanh toán:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Tên: ${userName ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              'Email: ${userEmail ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              'Số điện thoại: ${userPhone ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              'Địa chỉ: ${address ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Tên sách: $productName',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              'Số lượng: $quantityBill',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              'Tổng tiền: ${currencyFormat.format(totalAmount)}',
              style: TextStyle(
                  fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'Quét mã QR để thanh toán:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ngân hàng: Vietcombank\nSố tài khoản: 1016388651\nSố tiền: ${currencyFormat.format(totalAmount)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text('Xin vui lòng chờ...'),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      String signature = "some_signature";
                      int resultCode = 1;

                      await _addToCartWithSignature(
                          signature, resultCode, address ?? '');
                      await _addToBill(signature, resultCode, address ?? '');

                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Đơn hàng đang được xử lý...'),
                            content:
                                Text('Hãy theo dõi sản phẩm trong giỏ hàng'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                  );
                                },
                                child: Text('Đóng'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Đã thanh toán',
                        style: TextStyle(color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Hủy', style: TextStyle(color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addToCartWithSignature(
      String signature, int resultCode, String address) async {
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

    String? finalPrice;
    String? finalPromotionalPrice;

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

    var url = Uri.parse('http://192.168.1.171:8000/api/addcart');
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

  Future<void> _addToBill(
      String signature, int? resultCode, String address) async {
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

    String? finalPrice;
    String? finalPromotionalPrice;

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

    var url = Uri.parse('http://192.168.1.171:8000/api/addbill');
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
