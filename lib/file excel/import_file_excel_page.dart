import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;

class ImportExcelPage extends StatefulWidget {
  @override
  _ImportExcelPageState createState() => _ImportExcelPageState();
}

class _ImportExcelPageState extends State<ImportExcelPage> {
  List<List<dynamic>> _excelData = [];

  void _importExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);

      List<List<dynamic>> data = [];
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          data.add(row);
        }
      }

      setState(() {
        _excelData = data;
      });

      printExcelData();
    } else {
      print('No file selected');
    }
  }

  void printExcelData() {
    print('Dữ liệu từ tệp Excel:');
    for (var i = 0; i < _excelData.length; i++) {
      print('Dòng ${i + 1}:');
      for (var j = 0; j < _excelData[i].length; j++) {
        var cell = _excelData[i][j];
        if (cell != null) {
          print('   Cột ${j + 1}: ${cell.value}');
        } else {
          print('   Cột ${j + 1}: null');
        }
      }
      print('-------------------');
    }
  }

  void _addProduct() async {
    if (_excelData.isEmpty || _excelData.length < 2) {
      print('No data available to import products.');
      return;
    }

    for (var i = 1; i < _excelData.length; i++) {
      var category = _excelData[i][0]?.value?.toString() ?? '';
      var productName = _excelData[i][1]?.value?.toString() ?? '';
      var detailedDescription = _excelData[i][2]?.value?.toString() ?? '';
      var shortDescription = _excelData[i][3]?.value?.toString() ?? '';

      var price = 0.0;
      if (_excelData[i][4]?.value != null) {
        price = double.tryParse(_excelData[i][4].value.toString()) ?? 0.0;
      }

      var promotionalPrice = 0.0;
      if (_excelData[i][5]?.value != null) {
        promotionalPrice =
            double.tryParse(_excelData[i][5].value.toString()) ?? 0.0;
      }

      var imgProduct = _excelData[i][6]?.value?.toString() ?? '';
      var album = _excelData[i][7]?.value?.toString() ?? '';
      var pdfFile = _excelData[i][8]?.value?.toString() ?? '';

      var quantity = 0;
      if (_excelData[i][9]?.value != null) {
        quantity = int.tryParse(_excelData[i][9].value.toString()) ?? 0;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.171:8000/api/auth/addproduct'),
      );

      request.fields['category'] = category;
      request.fields['product_name'] = productName;
      request.fields['detailed_description'] = detailedDescription;
      request.fields['short_description'] = shortDescription;
      request.fields['price'] = price.toString();
      request.fields['promotional_price'] = promotionalPrice.toString();
      request.fields['imgproduct'] = imgProduct;
      request.fields['album'] = album;
      request.fields['pdf_file'] = pdfFile;
      request.fields['quantity'] = quantity.toString();

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          print('Product added successfully.');
        } else {
          print('Failed to add product. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding product: $e');
      }
    }
  }

  Widget _buildDataTable() {
    if (_excelData.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    List<DataColumn> columns = [];
    List<DataRow> rows = [];

    List<dynamic> headers = _excelData[0];
    for (var header in headers) {
      columns.add(DataColumn(label: Text(header.value.toString())));
    }

    for (var i = 1; i < _excelData.length; i++) {
      List<DataCell> dataCells = [];
      for (var j = 0; j < headers.length; j++) {
        var cell = _excelData[i][j];
        dataCells
            .add(DataCell(Text(cell != null ? cell.value.toString() : '')));
      }
      rows.add(DataRow(cells: dataCells));
    }

    return DataTable(
      columns: columns,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import File Excel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Import your Excel file:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _importExcelFile,
              icon: Icon(Icons.upload_file),
              label: Text('Choose File'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Import'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildDataTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
