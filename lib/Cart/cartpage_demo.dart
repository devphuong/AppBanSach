// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../page_home/ItemDetails.dart';

// class CartPageDemo extends StatefulWidget {
//   @override
//   _BooksPageState createState() => _BooksPageState();
// }

// class _BooksPageState extends State<CartPageDemo> {
//   List<ItemCartProduct> confirmedProducts = [];
//   List<ItemProduct> products = [];
//   bool isFetching = true;
//   bool isAdmin = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchProducts();
//     _getUserStatus();
//     _fetchCartItems();
//   }

//   Map<String, ItemProduct> productsMap =
//       {}; // Lưu trữ sản phẩm theo productName

//   Future<void> fetchProducts() async {
//     const String baseUrl = 'http://172.8.180.61:8000/api/products/';
//     final client = HttpClient();
//     client.connectionTimeout = Duration(minutes: 2);

//     int id = 1;
//     int retryCount = 5;
//     const retryDelay = Duration(seconds: 5);

//     setState(() {
//       isFetching = true;
//     });

//     while (retryCount > 0) {
//       try {
//         final request = await client.getUrl(Uri.parse('$baseUrl$id'));
//         request.headers.set(HttpHeaders.connectionHeader, 'keep-alive');

//         final response = await request.close();

//         if (response.statusCode == 200) {
//           final jsonString = await response.transform(utf8.decoder).join();
//           final Map<String, dynamic> data = jsonDecode(jsonString);
//           print(
//               '===================================Dữ liệu được lưu=================================== $productsMap');
//           try {
//             ItemProduct product = ItemProduct.fromJson(data);
//             productsMap[product.productName] = product;

//             print(
//                 '===================================Tất cả sản phẩm bảng products===================================');
//             print('id: ${product.id}');
//             print('Product Name: ${product.productName}');
//             print('Price: \$${product.price.toStringAsFixed(2)}');
//             print('Image URL: ${product.imgProduct}');
//             print('Album: ${product.album}');
//             print('---------------------------------------');
//           } catch (e) {
//             print('Error parsing product with ID: $id, error: $e');
//           }
//         } else if (response.statusCode == 404) {
//           break;
//         } else {
//           throw Exception('Failed to load product with ID: $id');
//         }

//         id++;
//       } on TimeoutException catch (e) {
//         print('Timeout while fetching product with ID: $id, error: $e');
//         retryCount--;
//         await Future.delayed(retryDelay);
//       } on SocketException catch (e) {
//         print('SocketException while fetching product with ID: $id, error: $e');
//         retryCount--;
//         await Future.delayed(retryDelay);
//       } on HttpException catch (e) {
//         print('HttpException while fetching product with ID: $id, error: $e');
//         retryCount--;
//         await Future.delayed(retryDelay);
//       } catch (e) {
//         print(
//             'Unexpected error while fetching product with ID: $id, error: $e');
//         retryCount--;
//         await Future.delayed(retryDelay);
//       }
//     }

//     setState(() {
//       isFetching = false;
//     });

//     print('Fetched products:');
//     productsMap.values.forEach((product) => print(product.productName));

//     await _fetchCartItems();
//   }

//   Future<void> _fetchCartItems() async {
//     try {
//       var id = 1;
//       bool hasMoreData = true;
//       List<ItemProduct> cartItems = [];

//       while (hasMoreData) {
//         var url = Uri.parse('http://172.8.180.61:8000/api/carts/$id');
//         var response = await http.get(url);

//         if (response.statusCode == 200) {
//           var jsonData = jsonDecode(response.body);

//           if (jsonData['status'] == true) {
//             var itemData = jsonData['item'];

//             var product = ItemCartProduct(
//               id: itemData['id'],
//               category: itemData['category'] ?? '',
//               productName: itemData['product_name'] ?? '',
//               shortDescription: itemData['short_description'] ?? '',
//               price: double.parse(itemData['price'].toString() ?? '0.0'),
//               promotionalPrice: double.parse(
//                   itemData['promotional_price'].toString() ?? '0.0'),
//               pdf_file: itemData['pdf_file'] ?? '',
//               quantityBill:
//                   int.parse(itemData['quantity_bill'].toString() ?? '0'),
//               success: int.parse(itemData['success'].toString() ?? '0'),
//               approving: int.parse(itemData['approving'].toString() ?? '0'),
//               full_name: itemData['full_name'] ?? '',
//               email: itemData['email'] ?? '',
//               phone_number: itemData['phone_number'] ?? '',
//               address: itemData['address'] ?? '',
//               selectedQuantity: 0,
//             );

//             if (product.approving == 1) {
//               print(
//                   "===================================Các Quyển Sách Chờ Xác Nhận===================================");
//               print("id: ${product.id}");
//               print("category: ${product.category}");
//               print("product_name: ${product.productName}");
//               print("short_description: ${product.shortDescription}");
//               print("price: \$${product.price}");
//               print("promotional_price: ${product.promotionalPrice}");
//               print("pdf_file: ${product.pdf_file}");
//               print("quantityBill: ${product.quantityBill}");
//               print("success: ${product.success}");
//               print("approving: ${product.approving}");

//               // Thêm sản phẩm vào danh sách sản phẩm từ fetchProducts nếu có trong productsMap
//               if (productsMap.containsKey(product.productName)) {
//                 var itemProduct = productsMap[product.productName]!;
//                 print(
//                     "itemProduct từ bảng products ==> ${itemProduct.productName} product.productName từ bảng carts ==> ${product.productName}");

//                 // In thông tin sản phẩm từ fetchProducts
//                 print(
//                     'Xử lý giữa bảng products == carts ==> product.productName of products: id=${itemProduct.id}, name=${itemProduct.productName}, price=${itemProduct.price}');

//                 cartItems.add(itemProduct); // Thêm sản phẩm vào cartItems
//                 print("Danh sách cartItems ==> ${itemProduct.productName}");
//               }
//             }

//             id++;
//           } else {
//             hasMoreData = false;
//             print('Failed to load cart item with id $id');
//           }
//         } else if (response.statusCode == 404) {
//           hasMoreData = false;
//         } else {
//           print(
//               'Failed to load cart items. Status code: ${response.statusCode}');
//           hasMoreData = false;
//         }
//       }

//       setState(() {
//         products =
//             cartItems; // Cập nhật products với các sản phẩm có approving=1
//         print("Các sản phẩm có approving: 1 ==> $products");
//       });
//     } catch (e) {
//       print('Error fetching cart items: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Đơn Hàng Chờ Xác Nhận'),
//       ),
//       body: isFetching
//           ? Center(child: CircularProgressIndicator())
//           : _buildProductGrid(),
//     );
//   }

//   Widget _buildProductGrid() {
//     return ListView.builder(
//       padding: EdgeInsets.all(10.0),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         var itemProduct = products[index];
//         var product = ItemCartProduct(
//           id: itemProduct.id,
//           category: '',
//           productName: itemProduct.productName,
//           shortDescription: '',
//           price: itemProduct.price,
//           promotionalPrice: 0.0,
//           pdf_file: itemProduct.pdf_file,
//           quantityBill: 0,
//           success: 1,
//           approving: 1,
//           full_name: '',
//           email: '',
//           phone_number: '',
//           address: '',
//           selectedQuantity: 0,
//         );
//         return _buildCard(itemProduct, product);
//       },
//     );
//   }

//   Widget _buildCard(ItemProduct itemProduct, ItemCartProduct product) {
//     print('Using image URL: ${itemProduct.imgProduct}');
//     print('quantityBill ==> ${product.quantityBill}');
//     return Padding(
//       padding: EdgeInsets.only(bottom: 15.0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 2.0,
//               blurRadius: 4.0,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildProductImage(itemProduct.imgProduct),
//             SizedBox(width: 15.0),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     itemProduct.productName,
//                     style: TextStyle(
//                       color: Color(0xFF575E67),
//                       fontFamily: 'Varela',
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 6.0),
//                   Text(
//                     '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(itemProduct.price)}',
//                     style: TextStyle(
//                       color: Colors.red[700],
//                       fontFamily: 'Varela',
//                       fontSize: 14.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (itemProduct.pdf_file.isNotEmpty) ...[
//                     SizedBox(height: 4.0),
//                     Text(
//                       'Giáo Trình Online',
//                       style: TextStyle(
//                         color: Colors.blueAccent,
//                         fontSize: 12.0,
//                       ),
//                     ),
//                   ],
//                   SizedBox(height: 10.0),
//                   Text(
//                     product.quantityBill.toString(),
//                     style: TextStyle(
//                       color: Colors.blueAccent,
//                       fontSize: 12.0,
//                     ),
//                   ),
//                   if (isAdmin)
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               await _handleProductReceived(product);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green[700],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             child: Text('Đã nhận'),
//                           ),
//                         ),
//                         SizedBox(width: 10.0),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               _updateProductStatus(product, false, true);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red[700],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             child: Text('Lỗi'),
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductImage(String imageUrl) {
//     return Padding(
//       padding: EdgeInsets.all(8.0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0),
//           color: Colors.grey[300],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.0),
//           child: imageUrl.isNotEmpty
//               ? CachedNetworkImage(
//                   imageUrl: imageUrl,
//                   errorWidget: (context, url, error) {
//                     print('Error loading image: $url, error: $error');
//                     return Center(
//                       child: Icon(Icons.image_not_supported, size: 50.0),
//                     );
//                   },
//                   height: 100.0,
//                   width: 100.0,
//                   fit: BoxFit.cover,
//                   httpHeaders: {'Connection': 'keep-alive'},
//                   fadeInDuration: Duration(seconds: 1),
//                   progressIndicatorBuilder: (context, url, downloadProgress) =>
//                       Center(
//                     child: CircularProgressIndicator(
//                       value: downloadProgress.progress,
//                       color: Colors.red[700],
//                     ),
//                   ),
//                 )
//               : Center(
//                   child: Icon(Icons.image_not_supported, size: 50.0),
//                 ),
//         ),
//       ),
//     );
//   }

//   Future<void> _handleProductReceived(ItemCartProduct product) async {
//     try {
//       Map<String, int> productNameToIdMap = await loadProductNameToIdMap();
//       var billUrl =
//           Uri.parse('http://172.8.180.61:8000/api/bills/${product.id}');
//       var billResponse = await http.get(billUrl);
//       print(
//           'ID của _handleProductReceived ${product.id} có quantity_bill ${product.quantityBill}');

//       if (!productNameToIdMap.containsKey(product.productName)) {
//         print('Product ${product.productName} not found in productNameToIdMap');
//         return;
//       }

//       int productId = productNameToIdMap[product.productName]!;

//       var productUrl =
//           Uri.parse('http://172.8.180.61:8000/api/products/$productId');
//       var productResponse = await http.get(productUrl);
//       print("product.id bảng bills ==> ${product.id} ");
//       print("productId bảng products ==> $productId");
//       print("productNameToIdMap ==> $productNameToIdMap");
//       print('ID tổng số lượng sản phẩm trong kho $productId');

//       if (productResponse.statusCode == 200) {
//         var productData = jsonDecode(productResponse.body);

//         int currentQuantity = productData['product']['quantity'];

//         await _updateProductStatus(product, true, false);

//         await _updateProductQuantity(
//             product.productName, currentQuantity - product.quantityBill);
//       } else {
//         print(
//             'Failed to get product details for product ${product.productName}');
//         print('Product Response status code: ${productResponse.statusCode}');
//         print('Product Response body: ${productResponse.body}');
//       }
//     } catch (e) {
//       print('Error handling product received: $e');
//     }
//   }

//   Future<void> _updateProductStatus(
//       ItemCartProduct product, bool success, bool unsuccessful) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? userStatus = prefs.getInt('userStatus') ?? 0;
//     print("userStatus _updateProductStatus ==> $userStatus");
//     String? category = product.category;
//     String? productName = product.productName;
//     String? shortDescription = product.shortDescription;
//     double? price = product.price;
//     double? promotionalPrice = product.promotionalPrice;
//     String? pdf_file = product.pdf_file;
//     int? quantityBill = product.quantityBill;

//     if (category == null ||
//         productName == null ||
//         shortDescription == null ||
//         price == null ||
//         pdf_file == null ||
//         quantityBill == null) {
//       print('Missing data in product');
//       return;
//     }

//     try {
//       var url =
//           Uri.parse('http://172.8.180.61:8000/api/updatecart/${product.id}');
//       var data = {
//         'id ItemCartProduct': product.id,
//         'category': category,
//         'product_name': productName,
//         'short_description': shortDescription,
//         'price': price,
//         'promotional_price': promotionalPrice ?? 0.0,
//         'pdf_file': pdf_file,
//         'quantity_bill': quantityBill,
//         'selected_quantity': product.selectedQuantity,
//         'success': success ? 1 : 0,
//         'unsuccessful': unsuccessful ? 1 : 0,
//         'approving': 0,
//       };

//       var response = await http.post(
//         url,
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(data),
//       );

//       if (response.statusCode == 200) {
//         print('Cart status updated successfully for product ${product.id}');
//       } else {
//         print(
//             'Failed to update cart status for product ${product.id}. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error updating cart status for product ${product.id}: $e');
//     }
//   }

//   Future<int> _updateProductQuantity(
//       String productName, int updatedQuantity) async {
//     try {
//       Map<String, int> productNameToIdMap = await loadProductNameToIdMap();

//       if (!productNameToIdMap.containsKey(productName)) {
//         print('Product $productName not found in productNameToIdMap');
//         return 0;
//       }

//       int productId = productNameToIdMap[productName]!;
//       var getUrl =
//           Uri.parse('http://172.8.180.61:8000/api/products/$productId');

//       var getResponse = await http.get(getUrl);
//       if (getResponse.statusCode != 200) {
//         print('Failed to fetch product data for product $productId');
//         print('Response body: ${getResponse.body}');
//         return 0;
//       }

//       var productData = jsonDecode(getResponse.body);
//       var productDetails = productData['product'];

//       print('Fetched product data for product $productId');
//       print('Category: ${productDetails['category']}');
//       print('Product Name: ${productDetails['product_name']}');
//       print('Detailed Description: ${productDetails['detailed_description']}');
//       print('Short Description: ${productDetails['short_description']}');
//       print('Price: ${productDetails['price']}');
//       print('Promotional Price: ${productDetails['promotional_price']}');
//       print('ImgProduct: ${productDetails['imgproduct']}');
//       print('Album: ${productDetails['album']}');
//       print('PDF File: ${productDetails['pdf_file']}');
//       print('Current Quantity: ${productDetails['quantity']}');

//       var data = {
//         'category': productDetails['category'],
//         'product_name': productDetails['product_name'],
//         'detailed_description': productDetails['detailed_description'],
//         'short_description': productDetails['short_description'],
//         'price': productDetails['price'],
//         'promotional_price': productDetails['promotional_price'],
//         'imgproduct': productDetails['imgproduct'],
//         'album': productDetails['album'],
//         'pdf_file': productDetails['pdf_file'],
//         'quantity': updatedQuantity,
//       };

//       var url =
//           Uri.parse('http://172.8.180.61:8000/api/updateproduct/$productId');
//       var response = await http.patch(
//         url,
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(data),
//       );

//       if (response.statusCode == 200) {
//         print('Product quantity updated successfully for product $productId');
//         return productDetails['quantity'];
//       } else if (response.statusCode == 404) {
//         print('Product with ID $productId not found');
//         print('Response body: ${response.body}');
//         return 0;
//       } else if (response.statusCode == 422) {
//         print('Validation error: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         return 0;
//       } else {
//         print(
//             'Failed to update product quantity for product $productId. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         return 0;
//       }
//     } catch (e) {
//       print('Error updating product quantity for product $productName: $e');
//       return 0;
//     }
//   }

//   Future<Map<String, int>> loadProductNameToIdMap() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     String? jsonMap = prefs.getString('productNameToIdMap');
//     if (jsonMap != null) {
//       Map<String, dynamic> map = jsonDecode(jsonMap);
//       Map<String, int> productNameToIdMap =
//           map.map((key, value) => MapEntry(key, value as int));
//       return productNameToIdMap;
//     } else {
//       return {};
//     }
//   }

//   Future<void> _getUserStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? userStatus = prefs.getInt('userStatus') ?? 0;
//     print('đang đăng nhập tk $userStatus');
//     setState(() {
//       isAdmin = (userStatus == 1);
//     });
//   }
// }

// class ItemCartProduct {
//   final int id;
//   final String category;
//   final String productName;
//   final String shortDescription;
//   final double price;
//   final double promotionalPrice;
//   final int quantityBill;
//   final int success;
//   final int approving;
//   final String full_name;
//   final String email;
//   final String phone_number;
//   final String address;
//   final String pdf_file;
//   final int selectedQuantity;

//   ItemCartProduct({
//     required this.id,
//     required this.category,
//     required this.productName,
//     required this.shortDescription,
//     required this.price,
//     required this.promotionalPrice,
//     required this.quantityBill,
//     required this.success,
//     required this.approving,
//     required this.full_name,
//     required this.email,
//     required this.phone_number,
//     required this.address,
//     required this.pdf_file,
//     required this.selectedQuantity,
//   });

//   @override
//   String toString() {
//     return 'ItemCartProduct{id: $id, category: $category, productName: $productName, shortDescription: $shortDescription, price: $price, promotionalPrice: $promotionalPrice, quantityBill: $quantityBill, success: $success, selectedQuantity: $selectedQuantity, full_name: $full_name, email: $email, phone_number: $phone_number, address: $address, pdf_file: $pdf_file}';
//   }
// }
