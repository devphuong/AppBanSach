import 'package:flutter/material.dart';

class CartPageNew extends StatefulWidget {
  @override
  _CartPageNewState createState() => _CartPageNewState();
}

class _CartPageNewState extends State<CartPageNew> {
  int productQuantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Text(
          'Giỏ hàng (2)',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Sửa',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildCartItem(),
                Divider(),
                _buildOutOfStockItem(),
              ],
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Text(
                'KARATTA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Sửa',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Image.network(
                'https://via.placeholder.com/80', // Thay URL ảnh
                width: 80,
                height: 80,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Túi Airbag Phiên bản hoa | Karatta...',
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'TÚI ĐEN - TAG HỒNG',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '₫690.000',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          productQuantity++;
                        });
                      },
                      icon: Icon(Icons.add)),
                  Text('$productQuantity'),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (productQuantity > 1) productQuantity--;
                        });
                      },
                      icon: Icon(Icons.remove)),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.green),
              SizedBox(width: 5),
              Text(
                'Giảm ₫300.000 phí vận chuyển đơn tối thiểu ₫0',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockItem() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Text(
                'Sản phẩm không tồn tại (1)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Sửa',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Image.network(
                'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                color: Colors.grey.withOpacity(0.5),
                colorBlendMode: BlendMode.modulate,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Son Kem 3CE Cho Viền Môi Mờ Ảo...',
                  style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.orange),
              SizedBox(width: 5),
              Text(
                'Tìm sản phẩm tương tự',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Text('Tất cả'),
              Spacer(),
              Text('Tổng thanh toán ₫0',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Mua hàng (0)',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
