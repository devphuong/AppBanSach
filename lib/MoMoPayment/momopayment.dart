import 'package:flutter/material.dart';
import 'package:tot_nghiep_ban_sach_thu_vien/MoMoPayment/mo_mo_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MoMoPaymentPage extends StatefulWidget {
  @override
  _MoMoPaymentPageState createState() => _MoMoPaymentPageState();
}

class _MoMoPaymentPageState extends State<MoMoPaymentPage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _initiatePayment() async {
    MoMoService.initiatePayment(
      amount: _amountController.text,
      companyName: _companyNameController.text,
      email: _emailController.text,
      title: _titleController.text,
      firstName: _firstNameController.text,
      middleName: _middleNameController.text,
      lastName: _lastNameController.text,
      address1: _address1Controller.text,
      address2: _address2Controller.text,
    );

    final url = 'http://172.8.180.66:8000/api/momopayment';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MoMo Payment Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email*'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name *'),
              ),
              TextField(
                controller: _middleNameController,
                decoration: InputDecoration(labelText: 'Middle Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name *'),
              ),
              TextField(
                controller: _address1Controller,
                decoration: InputDecoration(labelText: 'Address 1 *'),
              ),
              TextField(
                controller: _address2Controller,
                decoration: InputDecoration(labelText: 'Address 2'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Enter amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initiatePayment,
                child: Text('Request Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
