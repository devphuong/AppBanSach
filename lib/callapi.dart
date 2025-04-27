import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiDataPage extends StatefulWidget {
  const ApiDataPage({super.key});

  @override
  _ApiDataPageState createState() => _ApiDataPageState();
}

class _ApiDataPageState extends State<ApiDataPage> {
  List<ApiData> _apiDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchApiData();
  }

  Future<void> _fetchApiData() async {
    String username = 'OPCIT';
    String password = 'Welcome1';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    print(
        'Attempting to fetch API data with username: $username and password: $password');

    final response = await http.get(
      Uri.parse(
          'https://my427593.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPBPCSRSPB_Q0001QueryResults?\$select=CROOT_UUID,TROOT_UUID&\$format=json'),
      headers: {
        'Accept': 'application/json',
        'Authorization': basicAuth,
      },
    );

    // Print the response status and body
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final results = data['d']['results'];

      setState(() {
        _apiDataList = results.map<ApiData>((item) {
          final crootUuid = item['CROOT_UUID'] ?? 'No CROOT_UUID';
          final trootUuid = item['TROOT_UUID'] ?? 'No TROOT_UUID';
          return ApiData(crootUuid, trootUuid);
        }).toList();
      });
    } else {
      // Handle error
      print('Failed to load API data with status code: ${response.statusCode}');
      throw Exception('Failed to load API data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Data'),
      ),
      body: _apiDataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _apiDataList.length,
              itemBuilder: (context, index) {
                final apiData = _apiDataList[index];
                return ListTile(
                  title: Text(apiData.trootUuid),
                  subtitle: Text(apiData.crootUuid),
                );
              },
            ),
    );
  }
}

class ApiData {
  final String crootUuid;
  final String trootUuid;

  ApiData(this.crootUuid, this.trootUuid);
}
