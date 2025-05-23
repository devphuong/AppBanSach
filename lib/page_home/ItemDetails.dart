import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/Bill/billpage.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/Cart/cartpage.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/Cart/cartpagenew.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/TextToSpeech/texttospeechexample.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemProduct {
  final int id;
  final String category;
  final String productName;
  final String detailedDescription;
  final String shortDescription;
  final double price;
  final double? promotionalPrice;
  final String imgProduct;
  final List<String>? album;
  final String pdf_file;
  final int quantity;

  ItemProduct({
    required this.id,
    required this.category,
    required this.productName,
    required this.detailedDescription,
    required this.shortDescription,
    required this.price,
    this.promotionalPrice,
    required this.imgProduct,
    this.album,
    required this.pdf_file,
    required this.quantity,
  });

  factory ItemProduct.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'http://192.168.1.171:8000';
    String imgProductUrl = json['product']['imgproduct'] != null
        ? baseUrl + json['product']['imgproduct']
        : '';
    List<String>? albumUrls = json['product']['album'] != null
        ? (jsonDecode(json['product']['album']) as List<dynamic>)
            .cast<String>()
            .map((item) =>
                baseUrl + '/storage' + item.replaceFirst('public', ''))
            .toList()
        : null;

    String pdfUrl = json['product']['pdf_file'] != null
        ? baseUrl + json['product']['pdf_file']
        : '';

    print('PDF File URL: $pdfUrl');

    return ItemProduct(
      id: json['product']['id'] ?? 0,
      category: json['product']['category'] ?? '',
      productName: json['product']['product_name'] ?? '',
      detailedDescription: json['product']['detailed_description'] ?? '',
      shortDescription: json['product']['short_description'] ?? '',
      price: json['product']['price'] != null
          ? double.parse(json['product']['price'].toString())
          : 0.0,
      promotionalPrice: json['product']['promotional_price'] != null
          ? double.parse(json['product']['promotional_price'].toString())
          : null,
      imgProduct: imgProductUrl,
      album: albumUrls,
      pdf_file: pdfUrl,
      quantity: json['product']['quantity'] ?? 0,
    );
  }
}

class ItemDetail extends StatefulWidget {
  final String assetPath;
  final String cookieprice;
  final String cookiename;
  final ItemProduct product;

  ItemDetail({
    required this.assetPath,
    required this.cookieprice,
    required this.cookiename,
    required this.product,
  });

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool isReading = false; // Quản lý trạng thái đang đọc
  FlutterTts flutterTts = FlutterTts();
  int selectedQuantity = 1;
  int quantity_bill = 1;

  @override
  void initState() {
    super.initState();
    _saveSelectedQuantity(quantity_bill);
    _saveProductDetails();
    printSavedData();

    // Lắng nghe sự kiện đọc hoàn tất
    flutterTts.setCompletionHandler(() {
      setState(() {
        isReading = false; // Đọc xong, đặt trạng thái về false
      });
    });

    // Lắng nghe lỗi từ TTS
    flutterTts.setErrorHandler((msg) {
      setState(() {
        isReading = false; // Lỗi, đặt trạng thái về false
      });
    });
  }

  @override
  void dispose() {
    // Dừng đọc khi thoát khỏi trang
    flutterTts.stop();
    setState(() {
      isReading = false; // Đặt trạng thái về false
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("isReading: $isReading"); // Kiểm tra trạng thái khi giao diện được vẽ
    return FutureBuilder<int>(
      future: _getUserStatus(),
      builder: (context, snapshot) {
        // int? userStatus = snapshot.data;

        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share_rounded, color: Colors.red),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Hero(
                        tag: widget.assetPath,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: widget.product.imgProduct.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.product.imgProduct,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/no_image.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/no_image.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      widget.cookiename,
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.product.album != null &&
                        widget.product.album!.isNotEmpty)
                      _buildAlbumSection(widget.product.album!),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.red[400],
                          ),
                        ),
                        Text(
                          '${widget.cookieprice}',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.red[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        if (widget.product.promotionalPrice != null) ...[
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Đang khuyến mãi: ',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.red,
                                  ),
                                ),
                                WidgetSpan(
                                  child: SizedBox(width: 5),
                                ),
                                TextSpan(
                                  text:
                                      ' ₫${NumberFormat.currency(locale: 'vi', symbol: '').format(widget.product.promotionalPrice)}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color:
                                        const Color.fromARGB(255, 77, 77, 77),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Số lượng: ${widget.product.quantity}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.product.quantity == 0)
                      Text(
                        'Hết hàng',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                        ),
                      ),
                    SizedBox(height: 20.0),
                    Row(
                      children: [
                        Text(
                          'Chọn số lượng: ',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: selectedQuantity > 1
                              ? () {
                                  setState(() {
                                    selectedQuantity--;
                                    _saveSelectedQuantity(selectedQuantity);
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$selectedQuantity',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: selectedQuantity < widget.product.quantity
                              ? () {
                                  setState(() {
                                    selectedQuantity++;
                                    _saveSelectedQuantity(selectedQuantity);
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    if (widget.product.detailedDescription.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Mô tả chi tiết:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _readDescriptionWithAI(
                                      widget.product.detailedDescription);
                                },
                                icon: Icon(Icons.speaker, color: Colors.white),
                                label: Text(
                                  isReading ? 'Đang đọc...' : 'Hỗ trợ đọc',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isReading ? Colors.grey : Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              if (isReading) // Icon luôn hiển thị khi đang đọc
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.volume_up,
                                    color: Colors.blue,
                                    size: 24.0,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            widget.product.detailedDescription,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20.0),
                    if (widget.product.shortDescription.isNotEmpty)
                      _buildDescriptionSection(
                        'Mô tả ngắn:',
                        widget.product.shortDescription,
                      ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                    onPressed: () {},
                    child: Icon(Icons.favorite, color: Colors.white),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 80.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BillPage()),
                        //   MaterialPageRoute(
                        //       builder: (context) => MoMoPaymentPage()),
                      );
                    },
                    child: Text(
                      'Mua hàng',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _readDescriptionWithAI(String description) async {
    if (isReading) {
      // Nếu đang đọc, dừng đọc
      await flutterTts.stop();
      setState(() {
        isReading = false; // Đặt trạng thái về false
      });
    } else {
      // Nếu không đọc, bắt đầu đọc
      setState(() {
        isReading = true; // Đặt trạng thái là đang đọc
      });
      try {
        await flutterTts.speak(description);
      } catch (e) {
        print("Error: $e");
        setState(() {
          isReading = false; // Cập nhật trạng thái nếu có lỗi
        });
      }
    }
  }

  Widget _buildDescriptionSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          description,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildAlbumSection(List<String> album) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Album ảnh:',
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.0),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: album.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: album[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: Colors.red),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _saveProductDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('category', widget.product.category);
    prefs.setString('product_name', widget.product.productName);
    prefs.setString('detailed_description', widget.product.detailedDescription);
    prefs.setString('short_description', widget.product.shortDescription);
    prefs.setDouble('price', widget.product.price);
    prefs.setDouble(
        'promotional_price', widget.product.promotionalPrice ?? 0.0);
    prefs.setString('imgProduct', widget.product.imgProduct);
    prefs.setStringList('album', widget.product.album ?? []);
    prefs.setString('pdf_file', widget.product.pdf_file);
    prefs.setInt('quantity', widget.product.quantity);
  }

  Future<void> _saveSelectedQuantity(int quantity_bill) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('quantity_bill', quantity_bill);
  }
}

Future<void> printSavedData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? category = prefs.getString('category');
  String? productName = prefs.getString('product_name');
  String? detailedDescription = prefs.getString('detailed_description');
  String? shortDescription = prefs.getString('short_description');
  double? price = prefs.getDouble('price');
  double? promotionalPrice = prefs.getDouble('promotional_price');
  String? pdf_file = prefs.getString('pdf_file');
  String? imgProduct = prefs.getString('imgProduct');
  int? quantity = prefs.getInt('quantity');
  int? quantityBill = prefs.getInt('quantity_bill');
  int? selectedQuantity = prefs.getInt('selectedQuantity');
  List<String>? album = prefs.getStringList('album');

  print(
      '=====================================Thông tin ở trang chi tiết sản phẩm=====================================');
  print('Category: $category');
  print('Product Name: $productName');
  print('Detailed Description: $detailedDescription');
  print('Short Description: $shortDescription');
  print('Price: $price');
  print('Promotional Price: $promotionalPrice');
  print('PDF Link: $pdf_file');
  print('Tổng Kho: $quantity');
  print('imgProduct: $imgProduct');
  print('Quantity Bill: $quantityBill');
  print('Selected Quantity: $selectedQuantity');

  if (album != null && album.isNotEmpty) {
    print('Album:');
    for (String url in album) {
      print(url);
    }
  } else {
    print('Album: No images found');
  }
}

Future<int> _getUserStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userStatus') ?? 0;
}

Future<void> _launchPdf(String pdfUrl) async {
  print('_launchPdf link pdf $pdfUrl');

  if (!pdfUrl.toLowerCase().endsWith('.pdf')) {
    throw 'Invalid PDF URL $pdfUrl';
  }

  Uri uri = Uri.parse(pdfUrl);
  if (!await launchUrl(uri)) {
    throw 'Could not launch  $pdfUrl';
  }
}
