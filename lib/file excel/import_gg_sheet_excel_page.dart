import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImportExcelGgSheetPage extends StatefulWidget {
  @override
  _ImportExcelGgSheetPageState createState() => _ImportExcelGgSheetPageState();
}

class _ImportExcelGgSheetPageState extends State<ImportExcelGgSheetPage> {
  List<List<dynamic>> _excelData = [];
  TextEditingController _googleSheetLinkController = TextEditingController();

  Future<void> _importExcelFromGoogleSheet(String googleSheetLink) async {
    try {
      if (!googleSheetLink.contains('/edit')) {
        print('Invalid Google Sheets link.');
        return;
      }

      var sheetsId = googleSheetLink.split('/edit').first.split('/').last;

      var url =
          'https://docs.google.com/spreadsheets/d/$sheetsId/gviz/tq?tqx=out:json';

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonResponse =
            response.body.substring(47, response.body.length - 2);

        var jsonData = json.decode(jsonResponse);

        if (jsonData.containsKey('table') &&
            jsonData['table'].containsKey('rows')) {
          var rows = jsonData['table']['rows'];

          List<List<dynamic>> data = [];
          for (var row in rows) {
            var rowData =
                List<dynamic>.filled(jsonData['table']['cols'].length, 'null');
            for (var i = 0; i < row['c'].length; i++) {
              rowData[i] = row['c'][i] != null && row['c'][i].containsKey('v')
                  ? row['c'][i]['v'] ?? 'null'
                  : 'null';
            }
            data.add(rowData);
          }

          setState(() {
            _excelData = data;
          });

          printExcelData();
        } else {
          print(
              'Failed to fetch Google Sheets data. Missing "table" or "rows" in JSON response.');
        }
      } else {
        print(
            'Failed to fetch Google Sheets data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Google Sheets data: $e');
    }
  }

  Future<File?> _downloadFileimg(String url, String filename) async {
    int retryCount = 0;
    final client = http.Client();

    while (retryCount < 40) {
      try {
        final response = await client.get(
          Uri.parse(url),
          headers: {'Accept': 'application/octet-stream'},
        ).timeout(Duration(milliseconds: 90));
        if (response.statusCode == 200) {
          var tempDir = await getTemporaryDirectory();
          var tempPath = tempDir.path;
          var file = File('$tempPath/$filename');
          await file.writeAsBytes(response.bodyBytes);
          print('Đã tải tệp từ $url thành công.');
          return file;
        } else {
          print('Lỗi tải tệp từ: $url. Mã lỗi: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('Lỗi khi tải tệp: $e');
        retryCount++;
        if (retryCount >= 40) {
          print('ERRO download!');
          return null;
        }
        await Future.delayed(Duration(milliseconds: 90));
      }
    }
    return null;
  }

  Future<File?> _downloadFile(String url, String filename) async {
    int retryCount = 0;
    final dio = Dio();
    File file;

    try {
      var tempDir = await getTemporaryDirectory();
      var tempPath = tempDir.path;
      file = File('$tempPath/$filename');

      while (retryCount < 3) {
        try {
          final response = await dio.get(
            url,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              },
            ),
          );

          if (response.statusCode == 200) {
            final bytes = response.data;

            await file.writeAsBytes(bytes);
            print('File downloaded successfully.');
            return file;
          } else {
            print('Failed to download file: ${response.statusCode}');
            retryCount++;
            if (retryCount >= 3) {
              print('Exceeded retry attempts.');
              return null;
            }
            await Future.delayed(Duration(seconds: 5));
          }
        } catch (e) {
          print('Error downloading file: $e');
          retryCount++;
          if (retryCount >= 3) {
            print('Exceeded retry attempts.');
            return null;
          }
          await Future.delayed(Duration(seconds: 5));
        }
      }
    } catch (e) {
      print('Error initializing download: $e');
      return null;
    }

    return null;
  }

  void _sendDataToServer() async {
    if (_excelData.isEmpty || _excelData.length < 2) {
      print('No data available to import products.');
      return;
    }
    List<String> failedProducts = [];

    for (var i = 0; i < _excelData.length; i++) {
      var category = _excelData[i][0]?.toString() ?? '';
      var productName = _excelData[i][1]?.toString() ?? '';
      var detailedDescription = _excelData[i][2]?.toString() ?? '';
      var shortDescription = _excelData[i][3]?.toString() ?? '';

      var price = 0.0;
      if (_excelData[i][4] != null) {
        price = double.tryParse(_excelData[i][4].toString()) ?? 0.0;
      }

      var promotionalPrice = 0.0;
      if (_excelData[i][5] != null) {
        promotionalPrice = double.tryParse(_excelData[i][5].toString()) ?? 0.0;
      }

      var imgProduct = _excelData[i][6]?.toString() ?? '';
      var album = _excelData[i][7]?.toString() ?? '';
      var pdfFile = _excelData[i][8]?.toString() ?? '';

      var quantity = 0.0;
      if (_excelData[i][9] != null) {
        quantity = double.tryParse(_excelData[i][9].toString()) ?? 0.0;
      }

      print('===============Dữ liệu trước khi gửi lên server===============:');
      print('Dòng $i:');
      print('   Cột 1: $category');
      print('   Cột 2: $productName');
      print('   Cột 3: $detailedDescription');
      print('   Cột 4: $shortDescription');
      print('   Cột 5: $price');
      print('   Cột 6: $promotionalPrice');
      print('   Cột 7: $imgProduct');
      print('   Cột 8: $album');
      print('   Cột 9: $pdfFile');
      print('   Cột 10: $quantity');
      print('-------------------');

      try {
        var addCategoryResponse = await http.post(
          Uri.parse('http://192.168.30.244:8000/api/addcategory'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'category': category}),
        );

        if (addCategoryResponse.statusCode == 201) {
          print('Category added successfully.');
        } else {
          print(
              'Failed to add category. Status code: ${addCategoryResponse.statusCode}');
        }
      } catch (e) {
        print('Error adding category: $e');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.30.244:8000/api/auth/addproduct'),
      );

      request.fields['category'] = category;
      request.fields['product_name'] = productName;
      request.fields['detailed_description'] = detailedDescription;
      request.fields['short_description'] = shortDescription;
      request.fields['price'] = price.toString();
      request.fields['promotional_price'] = promotionalPrice.toString();
      request.fields['quantity'] = quantity.toString();

      if (imgProduct.isNotEmpty) {
        var imgProductUrl =
            'http://192.168.30.244:8000/storage/imgproducts/$imgProduct';
        try {
          var imgFile = await _downloadFileimg(imgProductUrl, 'imgproduct.jpg');
          if (imgFile != null) {
            var imgBytes = await imgFile.readAsBytes();
            var decodedImage = img.decodeImage(imgBytes);

            if (decodedImage != null && imgBytes.length > 2048) {
              decodedImage =
                  img.copyResize(decodedImage, width: 200, height: 200);
            }

            var tempDir = await getTemporaryDirectory();
            var tempPath = tempDir.path;
            var tempImgFile = File('$tempPath/temp_img.jpg')
              ..writeAsBytesSync(img.encodeJpg(decodedImage!));

            request.files.add(
              await http.MultipartFile.fromPath(
                'imgproduct',
                tempImgFile.path,
                contentType: MediaType.parse('image/jpeg'),
              ),
            );
            print('Ảnh đã upload $tempImgFile');
          } else {
            print('Error downloading imgProduct: $imgProductUrl');
          }
        } catch (e) {
          print('Error adding imgProduct: $e');
        }
      }

      if (album.isNotEmpty) {
        var albumPaths = album.split(',');
        for (var path in albumPaths) {
          var albumUrl =
              'http://192.168.30.244:8000/storage/albums/${path.trim()}';
          try {
            var albumFile = await _downloadFileimg(albumUrl, 'album.jpg');
            if (albumFile != null) {
              var imgBytes = await albumFile.readAsBytes();
              var decodedImage = img.decodeImage(imgBytes);

              if (decodedImage != null && imgBytes.length > 2048) {
                decodedImage =
                    img.copyResize(decodedImage, width: 200, height: 200);
              }

              var tempDir = await getTemporaryDirectory();
              var tempPath = tempDir.path;
              var tempImgFile = File('$tempPath/temp_album_img.jpg')
                ..writeAsBytesSync(img.encodeJpg(decodedImage!));

              request.files.add(
                await http.MultipartFile.fromPath(
                  'album[]',
                  tempImgFile.path,
                  contentType: MediaType.parse('image/jpeg'),
                ),
              );
              print('Album đã upload $tempImgFile');
            } else {
              print('Error downloading album file: $albumUrl');
            }
          } catch (e) {
            print('Error adding album file: $e');
          }
        }
      }

      if (pdfFile.isNotEmpty) {
        var pdfUrl = 'http://192.168.30.244:8000/storage/pdf/$pdfFile';
        try {
          var pdfDownloadedFile = await _downloadFile(pdfUrl, 'file.pdf');
          if (pdfDownloadedFile != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'pdf_file',
                pdfDownloadedFile.path,
                contentType: MediaType.parse('application/pdf'),
              ),
            );
            print("PDF đã được tải và thêm vào request: $pdfUrl");
          } else {
            print('Error downloading pdfFile: $pdfUrl');
            failedProducts.add(productName);
          }
        } catch (e) {
          print('Error adding pdfFile: $e');
          failedProducts.add(productName);
        }
      }

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 201) {
          print('Product added successfully.');
        } else {
          print('Failed to add product. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding product: $e');
      }
    }

    if (failedProducts.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Lỗi khi tải PDF'),
            content: Text(
              'Không thể tải file PDF cho các sản phẩm sau:\n${failedProducts.join('\n')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void printExcelData() {
    print('Dữ liệu từ tệp Excel:');
    for (var i = 0; i < _excelData.length; i++) {
      var row = _excelData[i];
      if (row.length >= 9) {
        var course = row[0];
        var courseName = row[1];
        var description = row[2];
        var shortDescription = row[3];
        var price = row[4];
        var promotionalPrice = row[5];
        var imgProduct = row[6];
        var album = row[7];
        var pdfFile = row[8];
        var quantity = row[9];

        print('Dòng ${i + 1}:');
        print('   category: $course');
        print('   product_name: $courseName');
        print('   detailed_description: $description');
        print('   short_description: $shortDescription');
        print('   price: \$${price.toStringAsFixed(2)}');
        print('   promotional_price: \$${promotionalPrice.toStringAsFixed(2)}');
        print('   imgproduct: $imgProduct');
        print('   Album: $album');
        print('   pdf_file: $pdfFile');
        print('   quantity: $quantity');
        print('-------------------');
      }
    }
  }

  Widget _buildDataTable() {
    if (_excelData.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    final columns = [
      'category',
      'product_name',
      'detailed_description',
      'short_description',
      'price',
      'promotional_price',
      'imgproduct',
      'album',
      'PDF',
      'quantity'
    ].map((header) => DataColumn(label: Text(header))).toList();

    final rows = _excelData
        .skip(0)
        .map(
          (row) => DataRow(
            cells: [
              DataCell(Text(row[0]?.toString() ?? '')),
              DataCell(Text(row[1]?.toString() ?? '')),
              DataCell(Text(row[2]?.toString() ?? '')),
              DataCell(Text(row[3]?.toString() ?? '')),
              DataCell(Text(row[4]?.toString() ?? '')),
              DataCell(Text(row[5]?.toString() ?? '')),
              DataCell(Text(row[6]?.toString() ?? '')),
              DataCell(Text(row[7]?.toString() ?? '')),
              DataCell(Text(row[8]?.toString() ?? '')),
              DataCell(Text(row[9]?.toString() ?? '')),
            ],
          ),
        )
        .toList();

    return DataTable(
      columns: columns,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Google Sheets Excel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paste your Google Sheets link:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _googleSheetLinkController,
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: 'Enter Google Sheets link',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (link) {
                _importExcelFromGoogleSheet(link);
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                var googleSheetLink = _googleSheetLinkController.text.trim();
                _importExcelFromGoogleSheet(googleSheetLink);
              },
              child: Text('Import'),
            ),
            ElevatedButton(
              onPressed: () {
                _sendDataToServer();
              },
              child: Text('Add'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _excelData.isEmpty
                    ? Center(child: Text('No data available.'))
                    : _buildDataTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
