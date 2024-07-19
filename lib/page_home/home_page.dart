import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/Cart/cartpage.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/login_screen.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/BottomNavigation.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemDetails.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemsList.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemsListCDCNPM.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemsListCNMMT.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemsListNQTM.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/page_home/ItemsListToan.dart';
import '../user/user_login_screen.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> notifications = [];
  List<ItemProduct> products = [];
  List<ItemProduct> filteredProducts = [];
  String searchQuery = '';
  bool _productsFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _clearSharedPreferences();
    _tabController = TabController(length: 5, vsync: this);
    _fetchProducts();
  }

  void _handleSearchQueryChange(String query) {
    _searchProducts(query);
    _showSearchResults();
  }

  Future<void> _fetchProducts() async {
    if (_productsFetched) return;

    try {
      final response = await http
          .get(Uri.parse('http://192.168.30.244:8000/api/all-product'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsData = data['data'];

        setState(() {
          products = productsData.map((product) {
            String baseUrl = 'http://192.168.30.244:8000/api/all-product';
            String imgProductUrl = product['imgproduct'] != null
                ? baseUrl + product['imgproduct']
                : '';

            List<String>? albumUrls = product['album'] != null
                ? (jsonDecode(product['album']) as List<dynamic>)
                    .cast<String>()
                    .map((item) =>
                        baseUrl + '/storage' + item.replaceFirst('public', ''))
                    .toList()
                : null;

            return ItemProduct(
              id: product['id'],
              category: product['category'],
              productName: product['product_name'],
              shortDescription: product['short_description'],
              price: double.parse(product['price']),
              promotionalPrice: double.parse(product['promotional_price']),
              pdf_file: product['pdf_file'] ?? '',
              quantity: product['quantity'],
              detailedDescription: product['detailed_description'],
              imgProduct: imgProductUrl,
              album: albumUrls,
            );
          }).toList();

          filteredProducts = products;
          _productsFetched = true;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _searchProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products.where((product) {
        return product.productName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final logger = Logger();

  void _showSearchResults() {
    if (searchQuery.isEmpty || filteredProducts.isEmpty) {
      return;
    }

    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) => SizedBox());

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + 70,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: filteredProducts.map((product) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        product.productName,
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        product.shortDescription,
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: Text(
                        '₫${NumberFormat.currency(locale: 'vi', symbol: '').format(product.price)}',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        try {
                          _navigateToItemDetail(product);
                          overlayEntry.remove();
                        } catch (e) {
                          logger.e('Error calling _navigateToItemDetail: $e');
                        }
                      },
                    ),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 1.0,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black45,
          ),
          onPressed: () {},
        ),
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[200],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: _handleSearchQueryChange,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm...",
                        hintStyle: TextStyle(color: Colors.red),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.red[700],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          PopupMenuButton<int>(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.red[700],
            ),
            itemBuilder: (BuildContext context) {
              return notifications.map((notification) {
                return PopupMenuItem<int>(
                  value: notifications.indexOf(notification),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        notification['type'] == 'success'
                            ? Icons.check_circle
                            : notification['type'] == 'approving'
                                ? Icons.access_time
                                : Icons.error,
                        color: notification['type'] == 'success'
                            ? Colors.green
                            : notification['type'] == 'approving'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sách: ${notification['product_name']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Số lượng: ${notification['quantity_bill']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            onSelected: (int index) {},
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onSelected: (String result) {
              if (result == 'Cài đặt') {
              } else if (result == 'Đăng xuất') {
                _logoutAndNavigateToLogin();
              } else if (result == 'Thông tin tài khoản') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLoginScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Cài đặt',
                child: Text('Cài đặt'),
              ),
              const PopupMenuItem<String>(
                value: 'Thông tin tài khoản',
                child: Text('Thông tin tài khoản'),
              ),
              const PopupMenuItem<String>(
                value: 'Đăng xuất',
                child: Text('Đăng xuất'),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 150,
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.only(left: 20),
              children: <Widget>[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Danh mục sách",
                      style: TextStyle(
                          fontFamily: "Varela",
                          fontSize: 20,
                          color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Xem thêm",
                            style: TextStyle(
                                fontFamily: "Varela",
                                fontSize: 16,
                                color: Colors.red[700]),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.red[700],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                    insets: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  isScrollable: true,
                  labelColor: Colors.red[700],
                  unselectedLabelColor: Color(0xff515c6f),
                  labelPadding: EdgeInsets.only(right: 30),
                  tabs: <Widget>[
                    Tab(
                      child: Text(
                        "Sản phẩm mới",
                        style: TextStyle(fontFamily: "Varela", fontSize: 17),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "CĐ Ô tô",
                        style: TextStyle(fontFamily: "Varela", fontSize: 17),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "CĐN QTM",
                        style: TextStyle(fontFamily: "Varela", fontSize: 17),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "CĐ CN CNPM",
                        style: TextStyle(fontFamily: "Varela", fontSize: 17),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "CĐN MMT",
                        style: TextStyle(fontFamily: "Varela", fontSize: 17),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ItemsList(
                    onItemTap: _navigateToItemDetail,
                    products: filteredProducts,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshProductsForToan,
                  child: ItemsListCDOTO(onItemTap: _navigateToItemDetail),
                ),
                RefreshIndicator(
                  onRefresh: _refreshProductsForTiengAnh,
                  child: ItemsListNQTM(onItemTap: _navigateToItemDetail),
                ),
                RefreshIndicator(
                  onRefresh: _refreshProductsForCoKhi,
                  child: ItemsListCDCNPM(onItemTap: _navigateToItemDetail),
                ),
                RefreshIndicator(
                  onRefresh: _refreshProductsForOTo,
                  child: ItemsListCNMMT(onItemTap: _navigateToItemDetail),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red[700],
        child: Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: CookingNavigator(),
    );
  }

  Future<void> _refreshProductsForToan() async {
    setState(() {});
  }

  Future<void> _refreshProductsForTiengAnh() async {
    setState(() {});
  }

  Future<void> _refreshProductsForCoKhi() async {
    setState(() {});
  }

  Future<void> _refreshProductsForOTo() async {
    setState(() {});
  }

  Future<void> _fetchCartItems() async {
    try {
      var id = 1;
      List<Map<String, dynamic>> newNotifications = [];

      bool hasMoreData = true;

      while (hasMoreData) {
        var url = Uri.parse('http://192.168.30.244:8000/api/carts/$id');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);

          if (jsonData['status'] == true) {
            var itemData = jsonData['item'];

            if (itemData['success'] == 1) {
              var notification = {
                'product_name': itemData['product_name'] ?? '',
                'quantity_bill': itemData['quantity_bill'] ?? 0,
                'type': 'success',
              };
              newNotifications.add(notification);
            }

            if (itemData['approving'] == 1) {
              var notification = {
                'product_name': itemData['product_name'] ?? '',
                'quantity_bill': itemData['quantity_bill'] ?? 0,
                'type': 'approving',
              };
              newNotifications.add(notification);
            }

            if (itemData['unsuccessful'] == 1) {
              var notification = {
                'product_name': itemData['product_name'] ?? '',
                'quantity_bill': itemData['quantity_bill'] ?? 0,
                'type': 'unsuccessful',
              };
              newNotifications.add(notification);
            }

            print('Data thông báo ==================== $jsonData');
            id++;
          } else {
            hasMoreData = false;
            print(
                'Failed to load cart item with id $id: ${jsonData['message']}');
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
        notifications = newNotifications;
      });

      print('Notifications: $notifications');
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> _logoutAndNavigateToLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _navigateToItemDetail(product) {
    if (product != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ItemDetail(
          assetPath: product.imgProduct,
          cookieprice:
              '₫${NumberFormat.currency(locale: 'vi', symbol: '').format(product.price)}',
          cookiename: product.productName,
          product: product,
        ),
      ));
    } else {
      print('Error: Product is null.');
    }
  }

  void _clearSharedPreferencesAndNavigateToCart() async {
    await _clearSharedPreferences();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  Future<void> _clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('category');
    await prefs.remove('product_name');
    await prefs.remove('detailed_description');
    await prefs.remove('short_description');
    await prefs.remove('price');
    await prefs.remove('promotional_price');
    await prefs.remove('pdf_file');
    await prefs.remove('quantity');
    await prefs.remove('quantity_bill');
    await prefs.remove('selectedQuantity');
    print('=====Cleared SharedPreferences for ItemDetail=====');
  }
}
