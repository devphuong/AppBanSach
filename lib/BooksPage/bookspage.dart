import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemDetailsSuccess.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<ItemProductSuccessBook> products = [];
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Map<String, ItemProductSuccessBook> productsMap = {};
  Future<void> fetchProducts() async {
    const String baseUrl = 'http://192.168.30.244:8000/api/products/';
    final client = HttpClient();
    client.connectionTimeout = Duration(minutes: 2);

    int id = 1;
    int retryCount = 5;
    const retryDelay = Duration(seconds: 5);

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
          print(
              '===================================Dữ liệu được lưu=================================== $productsMap');
          try {
            ItemProductSuccessBook product =
                ItemProductSuccessBook.fromJson(data);
            productsMap[product.productName] = product;

            print(
                '===================================Tất cả sản phẩm bảng products===================================');
            print('id: ${product.id}');
            print('Product Name: ${product.productName}');
            print('Price: \$${product.price.toStringAsFixed(2)}');
            print('Image URL: ${product.imgProduct}');
            print('Album: ${product.album}');
            print('---------------------------------------');
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

    setState(() {
      isFetching = false;
    });

    print('Fetched products:');
    productsMap.values.forEach((product) => print(product.productName));

    await _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      var id = 1;
      bool hasMoreData = true;
      List<ItemProductSuccessBook> cartItems = [];

      while (hasMoreData) {
        var url = Uri.parse('http://192.168.30.244:8000/api/carts/$id');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);

          if (jsonData['status'] == true) {
            var itemData = jsonData['item'];

            var price = itemData['price'] != null
                ? double.tryParse(itemData['price'].toString()) ?? 0.0
                : 0.0;
            var promotionalPrice = itemData['promotional_price'] != null
                ? double.tryParse(itemData['promotional_price'].toString()) ??
                    0.0
                : 0.0;
            var quantityBill = itemData['quantity_bill'] != null
                ? int.tryParse(itemData['quantity_bill'].toString()) ?? 0
                : 0;
            var success = itemData['success'] != null
                ? int.tryParse(itemData['success'].toString()) ?? 0
                : 0;

            var product = ItemCartProduct(
              id: itemData['id'],
              category: itemData['category'] ?? '',
              productName: itemData['product_name'] ?? '',
              shortDescription: itemData['short_description'] ?? '',
              price: price,
              promotionalPrice: promotionalPrice,
              pdf_file: itemData['pdf_file'] ?? '',
              quantityBill: quantityBill,
              success: success,
              selectedQuantity: 0,
            );

            if (product.success == 1 && product.pdf_file.isEmpty) {
              print(
                  "===================================Các Quyển Sách Đã Mua Hợp Lệ===================================");
              print("id: ${product.id}");
              print("category: ${product.category}");
              print("product_name: ${product.productName}");
              print("short_description: ${product.shortDescription}");
              print("price: \$${product.price}");
              print("promotional_price: ${product.promotionalPrice}");
              print("pdf_file: ${product.pdf_file}");
              print("success: ${product.success}");

              if (productsMap.containsKey(product.productName)) {
                var itemProduct = productsMap[product.productName]!;
                print(
                    "itemProduct từ bảng products ==> ${itemProduct.productName} product.productName từ bảng carts ==> ${product.productName}");

                print(
                    'Xử lý giữa bảng products == carts ==> product.productName of products: id=${itemProduct.id}, name=${itemProduct.productName}, price=${itemProduct.price}');

                cartItems.add(itemProduct);
                print("Danh sách cartItems ==> ${itemProduct.productName}");
              }
            }

            id++;
          } else {
            hasMoreData = false;
            print('Failed to load cart item with id $id');
          }
        } else if (response.statusCode == 404) {
          hasMoreData = false;
        } else {
          print(
              'Failed to load cart items. Status code: ${response.statusCode}');
          hasMoreData = false;
        }
      }

      setState(() {
        products = cartItems;
        print("Các sản phẩm có success:1 ==> $products");
      });
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Các Quyển Sách Đã Mua'),
      ),
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
        //
        var product = products[index];
        print(
            "===================================Các Quyển Sách Đã Mua Hiển Thị===================================");
        print(
            'Sản phẩm hiển thị: id=${product.id}, name=${product.productName}, price=${product.price}, imageURL=${product.imgProduct}, pdf_file=${product.pdf_file}');

        return _buildCard(product);
      },
    );
  }

  Widget _buildCard(ItemProductSuccessBook product) {
    print('Using image URL: ${product.imgProduct}');

    return Padding(
      padding: EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ItemDetailsSuccessPage(
              assetPath: product.imgProduct,
              cookieprice:
                  '₫${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(product.price)}',
              cookiename: product.productName,
              productSuccessbook: product,
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
              _buildProductImage(product.imgProduct),
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
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[700], size: 20.0),
                    Text(
                      'Đã Thanh Toán',
                      style: TextStyle(
                        fontFamily: 'Varela',
                        color: Colors.red[700],
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Hero(
        tag: imageUrl,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              errorWidget: (context, url, error) {
                print('Error loading image: $url, error: $error');
                return Icon(Icons.error);
              },
              height: 100.0,
              width: 100.0,
              fit: BoxFit.cover,
              httpHeaders: {'Connection': 'keep-alive'},
              fadeInDuration: Duration(seconds: 2),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  downloadProgress.progress == null
                      ? CircularProgressIndicator()
                      : SizedBox(),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 100.0,
        width: 100.0,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.image_not_supported, size: 50.0),
        ),
      );
    }
  }
}

class ItemCartProduct {
  final int id;
  final String category;
  final String productName;
  final String shortDescription;
  final double price;
  final double promotionalPrice;
  final String pdf_file;
  final int quantityBill;
  final int success;
  final int selectedQuantity;

  ItemCartProduct({
    required this.id,
    required this.category,
    required this.productName,
    required this.shortDescription,
    required this.price,
    required this.promotionalPrice,
    required this.pdf_file,
    required this.quantityBill,
    required this.success,
    required this.selectedQuantity,
  });

  @override
  String toString() {
    return 'ItemCartProduct{id: $id, category: $category, productName: $productName, shortDescription: $shortDescription, price: $price, promotionalPrice: $promotionalPrice, pdfFile: $pdf_file, quantityBill: $quantityBill, success: $success, selectedQuantity: $selectedQuantity}';
  }
}
