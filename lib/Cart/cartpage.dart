import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/home_page.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<ItemCartProduct> confirmedProducts = [];
  bool isAdmin = false;

  String category = '';
  String productName = '';
  String shortDescription = '';
  String detailed_description = '';
  String img_product = '';
  String album = '';
  double price = 0.0;
  double promotionalPrice = 0.0;
  String pdfFile = '';
  int quantityBill = 0;
  int quantity = 0;
  int selectedQuantity = 0;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getUserStatus();
    _fetchCartItems();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchCartItems();
    }
  }

  Future<void> _getUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userStatus = prefs.getInt('userStatus') ?? 0;
    setState(() {
      isAdmin = (userStatus == 1);
    });
  }

  Future<void> _fetchCartItems() async {
    try {
      var id = 1;
      bool hasMoreData = true;

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

            var product = ItemCartProduct(
              id: itemData['id'],
              category: itemData['category'] ?? '',
              productName: itemData['product_name'] ?? '',
              shortDescription: itemData['short_description'] ?? '',
              price: price,
              promotionalPrice: promotionalPrice,
              pdfFile: itemData['pdf_file'] ?? '',
              quantityBill: quantityBill,
              selectedQuantity: 0,
              full_name: itemData['full_name'] ?? '',
              email: itemData['email'] ?? '',
              phone_number: itemData['phone_number'] ?? '',
              address: itemData['address'] ?? '',
            );

            if (!confirmedProducts.any((p) => p.id == product.id)) {
              setState(() {
                confirmedProducts.add(product);
              });
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
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ Hàng'),
      ),
      body: confirmedProducts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCartItems,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: confirmedProducts.length,
                itemBuilder: (context, index) {
                  final product = confirmedProducts[index];
                  return ListTile(
                    title: Text(product.productName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mô tả: ${product.shortDescription}'),
                        Text('Giá: ${product.price}'),
                        Text('Giá khuyến mãi: ${product.promotionalPrice}'),
                        Text('Số lượng: ${product.quantityBill}'),
                        Text('Khách hàng: ${product.full_name}'),
                        Text('Email: ${product.email}'),
                        Text('Sdt: ${product.phone_number}'),
                        Text('Địa chỉ: ${product.address}'),
                        if (isAdmin)
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _handleProductReceived(product);
                                },
                                child: Text('Đã nhận'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _updateProductStatus(product, false, true);
                                },
                                child: Text('Lỗi'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {},
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        child: Icon(Icons.home),
      ),
    );
  }

  Future<int> _updateProductQuantity(String productName, int updatedQuantity,
      Map<String, int> productNameToIdMap) async {
    try {
      if (!productNameToIdMap.containsKey(productName)) {
        print('Product $productName not found in productNameToIdMap');
        return 0;
      }

      int productId = productNameToIdMap[productName]!;

      var productUrl =
          Uri.parse('http://192.168.30.244:8000/api/products/$productId');
      var productResponse = await http.get(productUrl);

      if (productResponse.statusCode == 200) {
        var productData = jsonDecode(productResponse.body);
        var productDetails = productData['product'];

        var data = {
          'category': productDetails['category'],
          'product_name': productDetails['product_name'],
          'detailed_description': productDetails['detailed_description'],
          'short_description': productDetails['short_description'],
          'price': productDetails['price'],
          'promotional_price': productDetails['promotional_price'],
          'imgproduct': productDetails['imgproduct'],
          'album': productDetails['album'],
          'pdf_file': productDetails['pdf_file'],
          'quantity': updatedQuantity, // Chỉ cập nhật số lượng
        };

        var url = Uri.parse(
            'http://192.168.30.244:8000/api/update-product/$productId');
        var response = await http.patch(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          print('Product quantity updated successfully for product $productId');
          return updatedQuantity;
        } else if (response.statusCode == 404) {
          print('Product with ID $productId not found');
          print('Response body: ${response.body}');
          return 0;
        } else if (response.statusCode == 422) {
          print('Validation error: ${response.statusCode}');
          print('Response body: ${response.body}');
          return 0;
        } else {
          print(
              'Failed to update product quantity for product $productId. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return 0;
        }
      } else {
        print('Failed to get product details for product $productId');
        print('Product Response status code: ${productResponse.statusCode}');
        print('Product Response body: ${productResponse.body}');
        return 0;
      }
    } catch (e) {
      print('Error updating product quantity for product $productName: $e');
      return 0;
    }
  }

  Future<Map<String, int>> loadProductNameToIdMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonMap = prefs.getString('productNameToIdMap');
    if (jsonMap != null) {
      Map<String, dynamic> map = jsonDecode(jsonMap);
      Map<String, int> productNameToIdMap =
          map.map((key, value) => MapEntry(key, value as int));
      return productNameToIdMap;
    } else {
      return {};
    }
  }

  Future<void> saveProductNameToIdMap(
      Map<String, int> productNameToIdMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String jsonMap = jsonEncode(productNameToIdMap);

    await prefs.setString('productNameToIdMap', jsonMap);
    print('Saved productNameToIdMap to SharedPreferences');
  }

  Future<void> _handleProductReceived(ItemCartProduct product) async {
    try {
      var allProductsUrl =
          Uri.parse('http://192.168.30.244:8000/api/all-product');
      var allProductsResponse = await http.get(allProductsUrl);

      if (allProductsResponse.statusCode == 200) {
        var allProductsData = jsonDecode(allProductsResponse.body);
        if (allProductsData['status'] == true) {
          var allProducts = allProductsData['data'] as List;

          Map<String, int> productNameToIdMap = {};
          for (var item in allProducts) {
            productNameToIdMap[item['product_name']] = item['id'];
          }

          if (productNameToIdMap.containsKey(product.productName)) {
            int productId = productNameToIdMap[product.productName]!;

            var productUrl =
                Uri.parse('http://192.168.30.244:8000/api/products/$productId');
            var productResponse = await http.get(productUrl);

            if (productResponse.statusCode == 200) {
              var productData = jsonDecode(productResponse.body);
              var productDetails = productData['product'];

              int currentQuantity = productDetails['quantity'];

              await _updateProductStatus(product, true, false);
              await _updateProductQuantity(product.productName,
                  currentQuantity - product.quantityBill, productNameToIdMap);
            } else {
              print(
                  'Failed to get product details for product ${product.productName}');
              print(
                  'Product Response status code: ${productResponse.statusCode}');
              print('Product Response body: ${productResponse.body}');
            }
          } else {
            print('Product ${product.productName} not found in all products');
          }
        } else {
          print('Failed to fetch all products data');
        }
      } else {
        print(
            'Failed to fetch all products. Status code: ${allProductsResponse.statusCode}');
        print('Response body: ${allProductsResponse.body}');
      }
    } catch (e) {
      print('Error handling product received: $e');
    }
  }

  Future<void> _updateProductStatus(
      ItemCartProduct product, bool success, bool unsuccessful) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userStatus = prefs.getInt('userStatus') ?? 0;

    String? category = product.category;
    String? productName = product.productName;
    String? shortDescription = product.shortDescription;
    double? price = product.price;
    double? promotionalPrice = product.promotionalPrice;
    String? pdfLink = product.pdfFile;
    int? quantityBill = product.quantityBill;

    if (category == null ||
        productName == null ||
        shortDescription == null ||
        price == null ||
        pdfLink == null ||
        quantityBill == null) {
      print('Missing data in product');
      return;
    }

    try {
      var url =
          Uri.parse('http://192.168.30.244:8000/api/updatecart/${product.id}');
      var data = {
        'category': category,
        'product_name': productName,
        'short_description': shortDescription,
        'price': price,
        'promotional_price': promotionalPrice ?? 0.0,
        'pdf_file': pdfLink,
        'quantity_bill': quantityBill,
        'selected_quantity': product.selectedQuantity,
        'success': success ? 1 : 0,
        'unsuccessful': unsuccessful ? 1 : 0,
        'approving': 0,
        'full_name': product.full_name,
        'email': product.email,
        'phone_number': product.phone_number,
        'address': product.address,
      };

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Cart status updated successfully for product ${product.id}');
      } else {
        print(
            'Failed to update cart status for product ${product.id}. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating cart status for product ${product.id}: $e');
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
  final String pdfFile;
  final int quantityBill;
  final int selectedQuantity;
  final String full_name;
  final String email;
  final String phone_number;
  final String address;

  ItemCartProduct({
    required this.id,
    required this.category,
    required this.productName,
    required this.shortDescription,
    required this.price,
    required this.promotionalPrice,
    required this.pdfFile,
    required this.quantityBill,
    required this.selectedQuantity,
    required this.full_name,
    required this.email,
    required this.phone_number,
    required this.address,
  });

  @override
  String toString() {
    return 'ItemCartProduct{id: $id, category: $category, productName: $productName, shortDescription: $shortDescription, price: $price, promotionalPrice: $promotionalPrice, pdfFile: $pdfFile, quantityBill: $quantityBill, selectedQuantity: $selectedQuantity, full_name: $full_name, email: $email, phone_number: $phone_number, address: $address}';
  }
}
