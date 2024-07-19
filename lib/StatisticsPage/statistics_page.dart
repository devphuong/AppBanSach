import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class Bill {
  final int id;
  final String category;
  final String productName;
  final String shortDescription;
  final String? price;
  final String? promotionalPrice;
  final String? pdfFile;
  final int quantityBill;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final int resultCode;
  final String signature;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.id,
    required this.category,
    required this.productName,
    required this.shortDescription,
    this.price,
    this.promotionalPrice,
    this.pdfFile,
    required this.quantityBill,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.resultCode,
    required this.signature,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      category: json['category'],
      productName: json['product_name'],
      shortDescription: json['short_description'],
      price: json['price'],
      promotionalPrice: json['promotional_price'],
      pdfFile: json['pdf_file'],
      quantityBill: json['quantity_bill'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      resultCode: json['resultCode'],
      signature: json['signature'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class BillResponse {
  final bool status;
  final List<Bill> data;

  BillResponse({required this.status, required this.data});

  factory BillResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Bill> billsList = list.map((i) => Bill.fromJson(i)).toList();
    return BillResponse(
      status: json['status'],
      data: billsList,
    );
  }
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<BillResponse> _futureBillResponse;
  DateTime? selectedDate;
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    _futureBillResponse = fetchBills();
  }

  Future<BillResponse> fetchBills() async {
    final response =
        await http.get(Uri.parse('http://192.168.30.244:8000/api/all-bill'));

    if (response.statusCode == 200) {
      return BillResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load bills');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Thống Kê'),
      ),
      body: FutureBuilder<BillResponse>(
        future: _futureBillResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.status) {
            return Center(child: Text('Không có dữ liệu'));
          } else {
            final bills = snapshot.data!.data
                .where((bill) => bill.resultCode == 0)
                .toList();

            Map<DateTime, double> revenueByDate = {};
            for (var bill in bills) {
              DateTime date = DateTime(bill.createdAt.year,
                  bill.createdAt.month, bill.createdAt.day);
              double price =
                  double.tryParse(bill.price ?? bill.promotionalPrice ?? '0') ??
                      0;
              double totalAmount = price * bill.quantityBill;

              if (revenueByDate.containsKey(date)) {
                revenueByDate[date] = revenueByDate[date]! + totalAmount;
              } else {
                revenueByDate[date] = totalAmount;
              }
            }

            List<ChartData> dailyChartData = revenueByDate.entries
                .map(
                    (entry) => ChartData(date: entry.key, revenue: entry.value))
                .toList();

            Map<String, double> revenueByMonth = {};
            for (var bill in bills) {
              String monthYear = DateFormat('MM/yyyy').format(bill.createdAt);
              double price =
                  double.tryParse(bill.price ?? bill.promotionalPrice ?? '0') ??
                      0;
              double totalAmount = price * bill.quantityBill;

              if (revenueByMonth.containsKey(monthYear)) {
                revenueByMonth[monthYear] =
                    revenueByMonth[monthYear]! + totalAmount;
              } else {
                revenueByMonth[monthYear] = totalAmount;
              }
            }

            List<ChartData> monthlyChartData = revenueByMonth.entries
                .map((entry) => ChartData(
                    date: DateFormat('MM/yyyy').parse(entry.key),
                    revenue: entry.value))
                .toList();

            List<ChartData> filteredDailyChartData = selectedDate != null
                ? dailyChartData
                    .where((data) => data.date == selectedDate)
                    .toList()
                : dailyChartData;
            List<ChartData> filteredMonthlyChartData = selectedMonth != null
                ? monthlyChartData
                    .where((data) =>
                        DateFormat('MM/yyyy').format(data.date) ==
                        selectedMonth)
                    .toList()
                : monthlyChartData;
            List<DateTime> availableDates = revenueByDate.keys.toList();
            List<String> availableMonths = revenueByMonth.keys.toList();

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<DateTime>(
                      hint: Text('Chọn Ngày'),
                      value: selectedDate,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDate = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<DateTime>(
                          value: null,
                          child: Text('Tất cả các ngày'),
                        ),
                        ...availableDates.map((date) {
                          return DropdownMenuItem<DateTime>(
                            value: date,
                            child: Text(DateFormat('dd/MM/yyyy').format(date)),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Container(
                    height: 300,
                    padding: EdgeInsets.all(8.0),
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        title: AxisTitle(text: 'Ngày'),
                        dateFormat: DateFormat('dd/MM/yyyy'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Doanh thu (VND)'),
                        numberFormat:
                            NumberFormat.simpleCurrency(decimalDigits: 0),
                      ),
                      title: ChartTitle(text: 'Doanh thu theo ngày'),
                      series: <ChartSeries>[
                        LineSeries<ChartData, DateTime>(
                          dataSource: filteredDailyChartData,
                          xValueMapper: (ChartData data, _) => data.date,
                          yValueMapper: (ChartData data, _) => data.revenue,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text('Chọn Tháng'),
                      value: selectedMonth,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tất cả các tháng'),
                        ),
                        ...availableMonths.map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Container(
                    height: 300,
                    padding: EdgeInsets.all(8.0),
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        title: AxisTitle(text: 'Tháng'),
                        dateFormat: DateFormat('MM/yyyy'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Doanh thu (VND)'),
                        numberFormat:
                            NumberFormat.simpleCurrency(decimalDigits: 0),
                      ),
                      title: ChartTitle(text: 'Doanh thu theo tháng'),
                      series: <ChartSeries>[
                        ColumnSeries<ChartData, DateTime>(
                          dataSource: filteredMonthlyChartData,
                          xValueMapper: (ChartData data, _) => data.date,
                          yValueMapper: (ChartData data, _) => data.revenue,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bills.length,
                      itemBuilder: (context, index) {
                        var bill = bills[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(bill.productName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Danh mục: ${bill.category}'),
                                Text('Giá: ${bill.price}'),
                                Text(
                                    'Giá khuyến mãi: ${bill.promotionalPrice}'),
                                Text('Số lượng: ${bill.quantityBill}'),
                                Text('Tên khách hàng: ${bill.fullName}'),
                                Text('Email: ${bill.email}'),
                                Text('Số điện thoại: ${bill.phoneNumber}'),
                                Text('Địa chỉ: ${bill.address}'),
                                Text('Chữ ký: ${bill.signature}'),
                                Text(
                                    'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(bill.createdAt)}'),
                                Text(
                                    'Ngày cập nhật: ${DateFormat('dd/MM/yyyy').format(bill.updatedAt)}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final double revenue;

  ChartData({required this.date, required this.revenue});
}
