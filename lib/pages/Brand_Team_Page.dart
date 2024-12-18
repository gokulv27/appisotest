import 'package:flutter/material.dart';

class BrandTeamScreen extends StatefulWidget {
  @override
  _BrandTeamScreenState createState() => _BrandTeamScreenState();
}

class _BrandTeamScreenState extends State<BrandTeamScreen> {
  final List<Map<String, dynamic>> _items = [];

  void _addItem() {
    setState(() {
      _items.add({
        "item": "",
        "brand": "",
        "description": "",
        "quantity": 1,
        "amount": 0,
      });
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      _items[index]["quantity"] += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_items[index]["quantity"] > 1) {
        _items[index]["quantity"] -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Brand Team", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add action if needed
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              color: Colors.grey[850], // Dark gray background for the card
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Item",
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[700],
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) => item["item"] = value,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Brand",
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[700],
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) => item["brand"] = value,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Description",
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[700],
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) => item["description"] = value,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.red),
                              onPressed: () => _decrementQuantity(index),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                item["quantity"].toString(),
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () => _incrementQuantity(index),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Amount",
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[700],
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            ),
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,


                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: _addItem,
          backgroundColor: Colors.green,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
