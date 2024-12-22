import 'package:flutter/material.dart';
import 'Brand_Team_Page.dart';
import 'Non-Brand_Team_Page.dart';
class VendorDetailsPage extends StatelessWidget {
  final String vendorName;

  VendorDetailsPage({required this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vendorName),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "Vendor Details: $vendorName",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NonBrandTeamPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text("Non-Brand Team"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BrandTeamScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text("Brand Team"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
