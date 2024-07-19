import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tot_nghiep_ban_sach_thu_vien/common/DialogHelper.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/custom_input_field.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/common/page_heading.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/currency_handling/currency_handling.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class AddproductPage extends StatefulWidget {
  const AddproductPage({Key? key}) : super(key: key);

  @override
  State<AddproductPage> createState() => _AddproductPageState();
}

class _AddproductPageState extends State<AddproductPage> {
  final _productFormKey = GlobalKey<FormState>();

  Future _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _selectedImage = imageTemporary);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  Future<void> _pickProfileImagealbum() async {
    try {
      final pickedImages = await ImagePicker().pickMultiImage();
      if (pickedImages.isEmpty) return;

      setState(() {
        _selectedAlbumImages.addAll(
          pickedImages.map((pickedImage) => File(pickedImage.path)).toList(),
        );
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  File? _selectedPdf;
  File? _selectedImage;
  TextEditingController _productnameController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _shortDescriptionController = TextEditingController();
  TextEditingController _promotionalPriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Form(
            key: _productFormKey,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const PageHeading(
                        title: 'Thêm sản phẩm',
                      ),
                      SizedBox(
                        width: 350,
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THÊM ẢNH ĐẠI DIỆN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 130,
                              height: 130,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            width: 130,
                                            height: 130,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: _pickProfileImage,
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade400,
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_sharp,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: 350,
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ALBUM ẢNH',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {});
                                    _pickProfileImagealbum();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8.0),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_sharp,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 100,
                              child: Scrollbar(
                                thickness: 8.0,
                                radius: Radius.circular(4.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _buildAlbumsWidgets(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Tên Sản Phẩm',
                        hintText: 'Nhập Tên Sản Phẩm...',
                        isDense: true,
                        controller: _productnameController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Name field is required!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        inputFormatters: [],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: Text(
                          'Chọn Danh Mục...',
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                        isDense: true,
                        decoration: InputDecoration(
                          labelText: 'Danh Mục',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'].toString(),
                            child: Text(
                              category['category'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _categoryController.text = _categories.firstWhere(
                                (c) => c['id'].toString() == value)['category'];
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Danh mục là bắt buộc!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text('Tên category đã chọn: ${_categoryController.text}'),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Mô Tả',
                        hintText: 'Nhập mô tả sản phẩm',
                        isDense: true,
                        controller: _descriptionController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Mô tả sản phẩm là bắt buộc!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        inputFormatters: [],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Mô Tả Ngắn',
                        hintText: 'Nhập mô tả ngắn sản phẩm',
                        isDense: true,
                        controller: _shortDescriptionController,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Mô tả ngắn sản phẩm là bắt buộc!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        inputFormatters: [],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Giá Sản Phẩm',
                        hintText: 'Nhập giá sản phẩm',
                        isDense: true,
                        controller: _priceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Giá sản phẩm là bắt buộc!';
                          }
                          if (double.tryParse(textValue.replaceAll(',', '')) ==
                              null) {
                            return 'Giá sản phẩm phải là số!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Giá Khuyến Mãi',
                        hintText: 'Nhập giá khuyến mãi',
                        isDense: true,
                        controller: _promotionalPriceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return null;
                          }
                          if (double.tryParse(textValue.replaceAll(',', '')) ==
                              null) {
                            return 'Giá khuyến mãi phải là số!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        labelText: 'Số Lượng',
                        hintText: 'Nhập số lượng sản phẩm',
                        isDense: true,
                        controller: _quantityController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Số lượng sản phẩm là bắt buộc!';
                          }
                          if (int.tryParse(textValue) == null) {
                            return 'Số lượng sản phẩm phải là số!';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: 350,
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THÊM FILE PDF CỦA SÁCH',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickPdfFile,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _selectedPdf != null
                                    ? Center(
                                        child: Text(
                                          'PDF Selected',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          'No PDF Selected',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: _handleAddProducts,
                        child: Text('Đăng'),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
      });
    }
  }

  void _handleAddProducts() async {
    if (_productFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang gửi dữ liệu..')),
      );

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.30.244:8000/api/auth/addproduct'),
        );

        String productName = _productnameController.text;
        String? category = _categoryController.text;
        String detailedDescription = _descriptionController.text;
        String shortDescription = _shortDescriptionController.text;
        double price = double.parse(_priceController.text.replaceAll(',', ''));
        double? promotionalPrice;
        if (_promotionalPriceController.text.isNotEmpty) {
          promotionalPrice = double.parse(
              _promotionalPriceController.text.replaceAll(',', ''));
        }
        int quantity = int.parse(_quantityController.text);

        if (price.isNaN ||
            (promotionalPrice != null && promotionalPrice.isNaN)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giá và giá khuyến mãi phải là số')),
          );
          return;
        }

        request.fields['product_name'] = productName;
        request.fields['category'] = category!;
        request.fields['detailed_description'] = detailedDescription;
        request.fields['short_description'] = shortDescription;
        request.fields['price'] = price.toString();
        request.fields['promotional_price'] =
            promotionalPrice?.toString() ?? '';
        request.fields['quantity'] = quantity.toString();

        // Hàm nén và thay đổi kích thước ảnh
        Future<File> resizeAndCompressImage(
            File imageFile, String tempPath, String tempFileName) async {
          var imgBytes = await imageFile.readAsBytes();
          var imgFile = img.decodeImage(imgBytes);

          if (imgBytes.length > 2048) {
            imgFile = img.copyResize(imgFile!, width: 200, height: 200);
          }

          var tempImgFile = File('$tempPath/$tempFileName')
            ..writeAsBytesSync(img.encodeJpg(imgFile!, quality: 60));

          return tempImgFile;
        }

        var tempDir = await getTemporaryDirectory();
        var tempPath = tempDir.path;

        if (_selectedImage != null) {
          var tempImgFile = await resizeAndCompressImage(
              _selectedImage!, tempPath, 'temp_img.jpg');
          var imgBytes = await tempImgFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'imgproduct',
              imgBytes,
              filename: 'temp_img.jpg',
              contentType: MediaType.parse('image/jpeg'),
            ),
          );
        }

        for (var image in _selectedAlbumImages) {
          var tempImgFile = await resizeAndCompressImage(
              image, tempPath, 'temp_album_img.jpg');
          var imgBytes = await tempImgFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'album[]',
              imgBytes,
              filename: 'temp_album_img.jpg',
              contentType: MediaType.parse('image/jpeg'),
            ),
          );
        }

        if (_selectedPdf != null) {
          var pdfBytes = await _selectedPdf!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'pdf_file',
              pdfBytes,
              filename: _selectedPdf!.path.split('/').last,
              contentType: MediaType.parse('application/pdf'),
            ),
          );
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          DialogHelper.showAlertDialog(
            context,
            'Thành công',
            'Sản phẩm đã được thêm thành công!',
            () {
              _productnameController.clear();
              _categoryController.clear();
              _descriptionController.clear();
              _shortDescriptionController.clear();
              _priceController.clear();
              _promotionalPriceController.clear();
              _quantityController.clear();
              _selectedImage = null;
              _selectedAlbumImages.clear();
              _selectedPdf = null;
            },
          );
        } else {
          var responseBody = jsonDecode(response.body);
          DialogHelper.showAlertDialog(
            context,
            'Lỗi',
            'Có lỗi xảy ra: ${responseBody['message'] ?? 'Vui lòng thử lại sau!'}',
            () {},
          );
          print('Lỗi: StatusCode ${response.statusCode}');
          print('Phản hồi: ${response.body}');
        }
      } catch (e) {
        print('Lỗi: $e');
        if (e is TimeoutException) {
          DialogHelper.showAlertDialog(
            context,
            'Lỗi máy chủ',
            'Quá thời gian kết nối. Vui lòng thử lại sau!',
            () {},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  void _showDialog(String title, String content) {
    DialogHelper.showAlertDialog(context, title, content);
  }

  List<File> _selectedAlbumImages = [];
  List<Widget> _buildAlbumsWidgets() {
    return _selectedAlbumImages.map((image) {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () {
            print('Selected image: ${image.path}');
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.30.244:8000/api/all-category'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          throw Exception('Failed to load categories');
        }
      } else {
        throw Exception('Failed to fetch data from API');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }
}
