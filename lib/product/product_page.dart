import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class Product {
  final int id;
  final String category;
  final String productName;
  final String detailedDescription;
  final String shortDescription;
  final String price;
  final String promotionalPrice;
  final String imgProduct;
  final String album;
  final String? pdfFile;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.category,
    required this.productName,
    required this.detailedDescription,
    required this.shortDescription,
    required this.price,
    required this.promotionalPrice,
    required this.imgProduct,
    required this.album,
    this.pdfFile,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: json['category'],
      productName: json['product_name'],
      detailedDescription: json['detailed_description'],
      shortDescription: json['short_description'],
      price: json['price'],
      promotionalPrice: json['promotional_price'],
      imgProduct: json['imgproduct'],
      album: json['album'],
      pdfFile: json['pdf_file'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'product_name': productName,
      'detailed_description': detailedDescription,
      'short_description': shortDescription,
      'price': price,
      'promotional_price': promotionalPrice,
      'imgproduct': imgProduct,
      'album': album,
      'pdf_file': pdfFile,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> _products = [];
  final String apiUrl = 'http://192.168.30.244:8000/api/all-product';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        _products = data.map((item) => Product.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> _updateProduct(Product product) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
            'http://192.168.30.244:8000/api/update-product/${product.id}'),
      );

      // Ensure all required fields are set
      if (product.category.isEmpty ||
          product.productName.isEmpty ||
          product.detailedDescription.isEmpty ||
          product.shortDescription.isEmpty ||
          product.quantity <= 0) {
        throw Exception('One or more required fields are empty.');
      }

      request.fields['category'] = product.category;
      request.fields['product_name'] = product.productName;
      request.fields['detailed_description'] = product.detailedDescription;
      request.fields['short_description'] = product.shortDescription;
      request.fields['quantity'] = product.quantity.toString();

      // Optional fields
      if (product.price.isNotEmpty) {
        request.fields['price'] = product.price;
      }
      if (product.promotionalPrice.isNotEmpty) {
        request.fields['promotional_price'] = product.promotionalPrice;
      }

      // Handle image file
      if (product.imgProduct.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'imgproduct',
          product.imgProduct,
        ));
      }

      // Handle album files
      if (product.album.isNotEmpty) {
        List<dynamic> albumPathsDynamic = json.decode(product.album);
        List<String> albumPaths = albumPathsDynamic.cast<String>();
        for (String path in albumPaths) {
          request.files.add(await http.MultipartFile.fromPath(
            'album[]',
            path,
          ));
        }
      }

      // Handle PDF file
      if (product.pdfFile != null && product.pdfFile!.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'pdf_file',
          product.pdfFile!,
        ));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Update successful: $responseData');
        setState(() {
          int index = _products.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _products[index] = product;
          }
        });
      } else {
        print('Failed to update product. Status code: ${response.statusCode}');
        print('Response body: $responseData');
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to update product');
    }
  }

  Future<void> _deleteProduct(int id) async {
    final response = await http
        .delete(Uri.parse('http://192.168.30.244:8000/api/delete-product/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _products.removeWhere((product) => product.id == id);
      });
    } else {
      throw Exception('Failed to delete product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Sản Phẩm'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: SingleChildScrollView(
          child: Column(
            children: _products
                .map((product) => ProductItem(
                    product: product,
                    onUpdate: _updateProduct,
                    onDelete: _deleteProduct))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  final Function(Product) onUpdate;
  final Function(int) onDelete;

  ProductItem(
      {required this.product, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(product.productName),
        subtitle: Text(product.shortDescription),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IconButton(
            //   icon: Icon(Icons.edit),
            //   onPressed: () {
            //     showDialog(
            //       context: context,
            //       builder: (context) => UpdateProductDialog(
            //         product: product,
            //         onUpdate: onUpdate,
            //       ),
            //     );
            //   },
            // ),
            // IconButton(
            //   icon: Icon(Icons.delete),
            //   onPressed: () async {
            //     await onDelete(product.id);
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class UpdateProductDialog extends StatefulWidget {
  final Product product;
  final Function(Product) onUpdate;

  UpdateProductDialog({required this.product, required this.onUpdate});

  @override
  _UpdateProductDialogState createState() => _UpdateProductDialogState();
}

class _UpdateProductDialogState extends State<UpdateProductDialog> {
  late TextEditingController _productNameController;
  late TextEditingController _shortDescriptionController;
  late TextEditingController _priceController;
  late TextEditingController _promotionalPriceController;
  late TextEditingController _quantityController;

  File? _imgProduct;
  List<File> _albumFiles = [];
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _productNameController =
        TextEditingController(text: widget.product.productName);
    _shortDescriptionController =
        TextEditingController(text: widget.product.shortDescription);
    _priceController = TextEditingController(text: widget.product.price);
    _promotionalPriceController =
        TextEditingController(text: widget.product.promotionalPrice);
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
  }

  Future<void> _pickImage(String type) async {
    FilePickerResult? result;
    if (type == 'imgProduct') {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _imgProduct = File(result!.files.single.path!);
        });
      }
    } else if (type == 'album') {
      result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        setState(() {
          _albumFiles = result!.paths.map((path) => File(path!)).toList();
        });
      }
    } else if (type == 'pdfFile') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() {
          _pdfFile = File(result!.files.single.path!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cập Nhật Sản Phẩm'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextField(
              controller: _shortDescriptionController,
              decoration: InputDecoration(labelText: 'Mô tả ngắn'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _promotionalPriceController,
              decoration: InputDecoration(labelText: 'Giá khuyến mại'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Số lượng'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text('Chọn ảnh sản phẩm:'),
            _imgProduct != null
                ? Image.file(_imgProduct!, width: 100, height: 100)
                : ElevatedButton(
                    onPressed: () => _pickImage('imgProduct'),
                    child: Text('Chọn ảnh sản phẩm'),
                  ),
            SizedBox(height: 10),
            Text('Chọn album hình ảnh:'),
            _albumFiles.isNotEmpty
                ? Column(
                    children: _albumFiles
                        .map(
                            (file) => Image.file(file, width: 100, height: 100))
                        .toList(),
                  )
                : ElevatedButton(
                    onPressed: () => _pickImage('album'),
                    child: Text('Chọn album hình ảnh'),
                  ),
            SizedBox(height: 10),
            Text('Chọn tệp PDF:'),
            _pdfFile != null
                ? Text(_pdfFile!.path.split('/').last)
                : ElevatedButton(
                    onPressed: () => _pickImage('pdfFile'),
                    child: Text('Chọn tệp PDF'),
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final updatedProduct = Product(
              id: widget.product.id,
              category: widget.product.category,
              productName: _productNameController.text,
              detailedDescription: widget.product.detailedDescription,
              shortDescription: _shortDescriptionController.text,
              price: _priceController.text,
              promotionalPrice: _promotionalPriceController.text,
              imgProduct: _imgProduct?.path ?? widget.product.imgProduct,
              album: jsonEncode(_albumFiles.map((f) => f.path).toList()),
              pdfFile: _pdfFile?.path ?? widget.product.pdfFile,
              quantity: int.parse(_quantityController.text),
              createdAt: widget.product.createdAt,
              updatedAt: DateTime.now(),
            );

            widget.onUpdate(updatedProduct);

            Navigator.of(context).pop();
          },
          child: Text('Cập Nhật'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Hủy'),
        ),
      ],
    );
  }
}
