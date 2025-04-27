import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode/barcode.dart';

class BillDetailPage extends StatefulWidget {
  @override
  _BillDetailPageState createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  int? savedMaxIdBillDetailPage;
  String? category;
  String? productName;
  String? shortDescription;
  double? price;
  double? promotionalPrice;
  double? totalAmount;
  String? pdfFile;
  int? quantityBill;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? address;
  int? resultCode;
  String? signature;
  String? createdAt;
  String? updatedAt;

  @override
  void initState() {
    super.initState();
    getStatusBill();
  }

  Future<void> getStatusBill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? statusBill = prefs.getInt('statusbill');

    if (statusBill != null) {
      if (statusBill == 0) {
        print('Status Bill: Thành công');
      } else if (statusBill == 1) {
        print('Status Bill: Quá hạn');
      } else {
        print('Status Bill: Giá trị không xác định');
      }
    } else {
      print('Không có dữ liệu Status Bill');
    }
    await _loadMaxIdAndFetchBillDetails(statusBill!);
  }

  Future<void> _loadMaxIdAndFetchBillDetails(int statusBill) async {
    var url = Uri.parse('http://192.168.1.171:8000/api/all-momopayment');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var momosList = jsonResponse['data'] as List<dynamic>;

        if (momosList.isNotEmpty) {
          var validMomos =
              momosList.where((momo) => momo['signature'] != null).toList();
          if (validMomos.isNotEmpty) {
            int maxIdBillDetailPage = validMomos
                .map((momo) => momo['id'] as int)
                .reduce((a, b) => a > b ? a : b);

            if (statusBill == 1) {
              print(
                  '=============================================== THỜI GIAN THANH TOÁN QUÁ HẠN BillDetailPage!===============================================');
            } else {
              final response = await http.get(
                Uri.parse(
                    'http://192.168.1.171:8000/api/bills/$maxIdBillDetailPage'),
              );
              print('maxIdBillDetailPage ==> $maxIdBillDetailPage');
              print('statusBill ==> $statusBill');
              if (response.statusCode == 200) {
                final Map<String, dynamic> data = json.decode(response.body);
                final bill = data['bill'];

                setState(() {
                  category = bill['category'];
                  productName = bill['product_name'];
                  shortDescription = bill['short_description'];
                  price = bill['price'] != null
                      ? double.tryParse(bill['price'])
                      : null;
                  promotionalPrice = bill['promotional_price'] != null
                      ? double.tryParse(bill['promotional_price'])
                      : null;
                  totalAmount = bill['totalAmount'] != null
                      ? double.tryParse(bill['totalAmount'])
                      : null;
                  pdfFile = bill['pdf_file'];
                  quantityBill = bill['quantity_bill'];
                  fullName = bill['full_name'];
                  email = bill['email'];
                  phoneNumber = bill['phone_number'];
                  address = bill['address'];
                  resultCode = bill['resultCode'];
                  signature = bill['signature'];
                  createdAt = bill['created_at'];
                  updatedAt = bill['updated_at'];
                });
              } else {
                // Handle error
                print('Failed to load bill details');
              }
            }
          } else {
            print(
                '=============================================== THỜI GIAN THANH TOÁN QUÁ HẠN BillDetailPage! TB 2 ===============================================');
          }
        } else {
          print(
              '=============================================== THỜI GIAN THANH TOÁN QUÁ HẠN BillDetailPage! TB 3 ===============================================');
        }
      } else {
        print(
            'Failed to fetch momos list. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching signature: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String paymentStatus = '';
    if (resultCode != null) {
      if (resultCode.toString().startsWith('1')) {
        paymentStatus = 'Thanh toán thất bại';
      } else if (resultCode.toString().startsWith('0')) {
        paymentStatus = 'Thanh toán thành công';
      } else {
        paymentStatus = 'Trạng thái thanh toán không xác định';
      }
    } else {
      paymentStatus = 'Chưa có thông tin trạng thái thanh toán';
    }

    final Barcode barcode = Barcode.code128();
    final barcodeSvg = barcode.toSvg(signature ?? '', width: 200, height: 100);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Hóa Đơn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin Hóa Đơn:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              'Loại Sách: ${category ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Tên Sách: ${productName ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Mô tả ngắn: ${shortDescription ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Giá: ${price != null ? currencyFormat.format(price) : 'Sản phẩm đang khuyến mãi!'}',
              style: TextStyle(fontSize: 18.0, color: Colors.red),
            ),
            SizedBox(height: 10.0),
            Text(
              'Giá khuyến mãi: ${promotionalPrice != null ? currencyFormat.format(promotionalPrice) : 'Hết hạn!'}',
              style: TextStyle(fontSize: 18.0, color: Colors.red),
            ),
            SizedBox(height: 10.0),
            if (pdfFile != null && pdfFile!.isNotEmpty)
              Text(
                'PDF File: Sau thanh toán, hãy qua lại trang Mua Hàng và kiểm tra thông báo của chúng tôi!',
                style: TextStyle(fontSize: 18.0),
              ),
            SizedBox(height: 10.0),
            Text(
              'Số lượng sách: ${quantityBill ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Người đặt hàng: ${fullName ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Email: ${email ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Số điện thoại: ${phoneNumber ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Địa chỉ: ${address ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Mã giao dịch:',
              style: TextStyle(fontSize: 10.0),
            ),
            if (signature != null)
              Container(
                color: Colors.white,
                child: SvgPicture.string(
                  barcodeSvg ?? '',
                  height: 100,
                ),
              ),
            SizedBox(height: 10.0),
            Text(
              'Ngày Tạo: ${createdAt ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Ngày Cập Nhật: ${updatedAt ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Mã Kết Quả: ${resultCode ?? 'Chưa có thông tin'}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Tổng thanh toán: ${totalAmount != null ? currencyFormat.format(totalAmount) : 'Chưa có thông tin'}, ',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              paymentStatus,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: resultCode.toString().startsWith('0')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
