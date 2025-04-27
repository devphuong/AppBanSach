import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'ItemDetails.dart';

typedef void ItemTapCallback(ItemProduct product);

class ItemsList extends StatefulWidget {
  final ItemTapCallback onItemTap;

  ItemsList({required this.onItemTap, required List<ItemProduct> products});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List<ItemProduct> products = [];
  List<String> loadedImageUrls = [];
  bool isFetching = true;
  late String email;
  late String password;

  @override
  void initState() {
    super.initState();
    _initializeData();
    //fetchProducts();
  }

  Future<void> _initializeData() async {
    await fetchUserAccountStatus(); // Đảm bảo tất cả print của fetchUserAccountStatus() được in trước
    fetchProducts(); // Gọi sau khi fetchUserAccountStatus() hoàn thành
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      password = prefs.getString('password') ?? '';
      print('Email lưu ==> $email');
      print('Passwword lưu ==> $password');
    });
  }

  Future<int> fetchUserAccountStatus() async {
    try {
      await _loadCredentials();

      // Kiểm tra email và password nếu trống thì in thông báo "Đây là tài khoản khách"
      if (email.isEmpty || password.isEmpty) {
        print('Đây là tài khoản khách');
        return -1; // Trả về giá trị mặc định khi email hoặc password không có
      }

      var response = await http.post(
        Uri.parse('http://192.168.1.171:8000/api/auth/users'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var data = responseData['data'];
        int status = data['role_id'] ??
            -1; // Sử dụng giá trị mặc định là -1 nếu role_id là null

        // Kiểm tra giá trị role_id và in thông báo
        if (status == 1) {
          print('Xin chào admin');
        } else if (status == 0) {
          print('Đây là tài khoản thành viên');
        } else {
          print(
              'Đây là tài khoản khách'); // Hiển thị khi status là null (trở thành -1)
        }

        print('Email đăng nhập lấy Status ===> $email');
        print('Password đăng nhập lấy Status ===> $password');
        print('role_id từ API: $status');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userStatus', status);

        return status;
      } else {
        return -1; // Trả về -1 nếu không thể lấy dữ liệu từ API
      }
    } catch (error) {
      print('Error fetching user account: $error');
      return -1; // Trả về -1 nếu có lỗi trong quá trình thực thi
    }
  }

  Future<void> fetchProducts() async {
    const String baseUrl = 'http://192.168.1.171:8000/api/products/';
    final client = HttpClient();
    client.connectionTimeout = Duration(minutes: 2);

    List<ItemProduct> fetchedProducts = [];
    Map<String, int> productNameToIdMap = {};
    List<String?> imageUrls = [];
    int id = 1;
    int retryCount = 5;
    const retryDelay = Duration(seconds: 480);

    setState(() {
      isFetching = true;
    });

    while (retryCount > 0) {
      try {
        final request = await client.getUrl(Uri.parse('$baseUrl$id'));
        request.headers.set(HttpHeaders.connectionHeader, 'keep-alive');

        final response = await request.close();

        if (response.statusCode == 200) {
          final jsonString = await response.transform(utf8.decoder).join();
          final Map<String, dynamic> data = jsonDecode(jsonString);
          try {
            ItemProduct product = ItemProduct.fromJson(data);

            if (product.category.isNotEmpty) {
              fetchedProducts.add(product);
              productNameToIdMap[product.productName] = product.id;

              if (product.imgProduct.isNotEmpty) {
                imageUrls.add(product.imgProduct);
              } else {
                imageUrls.add('');
              }
              print('category: ${product.category}');
              print('Product Name: ${product.productName}');
              print('Price: \$${product.price.toStringAsFixed(2)}');
              print('Image URL: ${product.imgProduct}');
              print('Album: ${product.album}');
              print('---------------------------------------');
            }
          } catch (e) {
            print('Error parsing product with ID: $id, error: $e');
          }
        } else if (response.statusCode == 404) {
          break;
        } else {
          throw Exception('Failed to load product with ID: $id');
        }

        id++;
      } on TimeoutException catch (e) {
        print('Timeout while fetching product with ID: $id, error: $e');
        retryCount--;
        await Future.delayed(retryDelay);
      } on SocketException catch (e) {
        print('SocketException while fetching product with ID: $id, error: $e');
        retryCount--;
        await Future.delayed(retryDelay);
      } on HttpException catch (e) {
        print('HttpException while fetching product with ID: $id, error: $e');
        retryCount--;
        await Future.delayed(retryDelay);
      } catch (e) {
        print(
            'Unexpected error while fetching product with ID: $id, error: $e');
        retryCount--;
        await Future.delayed(retryDelay);
      }
    }

    await saveProductNameToIdMap(productNameToIdMap);

    setState(() {
      products = fetchedProducts;
      loadedImageUrls = imageUrls.cast<String>();
      isFetching = false;
    });

    print('Loaded image URLs:');
    loadedImageUrls.forEach((url) => print(url));
  }

  Future<void> saveProductNameToIdMap(
      Map<String, int> productNameToIdMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String jsonMap = jsonEncode(productNameToIdMap);

    await prefs.setString('productNameToIdMap', jsonMap);
    print('Saved productNameToIdMap to SharedPreferences');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF8),
      body: isFetching
          ? Center(child: CircularProgressIndicator())
          : _buildProductGrid(),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildCard(products[index], loadedImageUrls[index]);
      },
    );
  }

  Widget _buildCard(ItemProduct product, String imageUrl) {
    print('Using image URL: $imageUrl');

    return Padding(
      padding: EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ItemDetail(
              assetPath: product.imgProduct,
              cookieprice:
                  '₫${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(product.price)}',
              cookiename: product.productName,
              product: product,
            ),
          ));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3.0,
                blurRadius: 5.0,
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.favorite_border, color: Colors.red[700]),
                  ],
                ),
              ),
              _buildProductImage(imageUrl),
              SizedBox(height: 7.0),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(product.price)}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontFamily: 'Varela',
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        product.productName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF575E67),
                          fontFamily: 'Varela',
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    if (product.pdf_file.isNotEmpty) ...[
                      SizedBox(height: 1.0),
                      Text(
                        'Giáo Trình Online',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 7.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/default_image.jpg',
        fit: BoxFit.contain,
        height: 110.0,
        width: 110.0,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        height: 110.0,
        width: 110.0,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
  }
}
