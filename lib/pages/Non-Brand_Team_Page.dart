import 'package:flutter/material.dart';

class NonBrandTeamPage extends StatefulWidget {
  @override
  _NonBrandTeamPageState createState() => _NonBrandTeamPageState();
}

class _NonBrandTeamPageState extends State<NonBrandTeamPage> {
  List<Map<String, dynamic>> _items = [];

  void _addItem() {
    setState(() {
      _items.add({"name": "", "description": "", "quantity": "", "amount": ""});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Non-Brand Team")),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Item Name"),
                      onChanged: (value) => item["name"] = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Description"),
                      onChanged: (value) => item["description"] = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Quantity"),
                      onChanged: (value) => item["quantity"] = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Amount (<2000)"),
                      onChanged: (value) => item["amount"] = value,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            );
          }),
          ElevatedButton(
            onPressed: _addItem,
            child: Text("Add Item"),
          ),
          ElevatedButton(
            onPressed: () {
              // Upload bill logic here.
            },
            child: Text("Upload Bill"),
          ),
        ],
      ),
    );
  }
}
