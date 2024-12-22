import 'package:flutter/material.dart';
import 'vendormappage.dart';

class VendorSelectionPage extends StatefulWidget {
  final int projectId;

  const VendorSelectionPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _VendorSelectionPageState createState() => _VendorSelectionPageState();
}

class _VendorSelectionPageState extends State<VendorSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Select the Option",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        child:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Add your "Select Vendor" onPressed functionality here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>VendorMapPage()),
                );
              },
              child: const Text(
                "Select Vendor",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            const SizedBox(height: 20), // Add spacing between the buttons
            TextButton(
              onPressed: () {
                // Add your "Create Vendor" onPressed functionality here

              },
              child: const Text(
                "Create Vendor",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),)
    );
  }
}
