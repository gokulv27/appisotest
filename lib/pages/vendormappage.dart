import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'vendor_details_page.dart';

class VendorMapPage extends StatefulWidget {
  @override
  _VendorMapPageState createState() => _VendorMapPageState();
}

class _VendorMapPageState extends State<VendorMapPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _vendors = [
    {"name": "Vendor 1", "latitude": 37.7749, "longitude": -122.4194},
    {"name": "Vendor 2", "latitude": 37.7849, "longitude": -122.4094},
    {"name": "Vendor 3", "latitude": 37.7949, "longitude": -122.4294},
    {"name": "Vendor 4", "latitude": 37.7549, "longitude": -122.4394},
    {"name": "Vendor 5", "latitude": 37.7649, "longitude": -122.4594},
  ];

  List<Map<String, dynamic>> _filteredVendors = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;

  BitmapDescriptor? _shoppingCartIcon;

  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#000000"
        }
      ]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _filteredVendors = _vendors;
    _loadCustomMarkerIcon();
  }

  Future<void> _initializeLocation() async {
    try {
      await _checkLocationPermission();
      await _getCurrentLocation();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _loadCustomMarkerIcon() async {
    _shoppingCartIcon = await _createCustomMarker(
      const Icon(
        Icons.shopping_cart,
        size: 84.0,
        color: Colors.green,
      ),
    );
  }

  Future<BitmapDescriptor> _createCustomMarker(Icon icon) async {
    const double markerSize = 100.0;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.transparent;

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, markerSize, markerSize),
      paint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.icon!.codePoint),
        style: TextStyle(
          fontSize: markerSize / 2,
          fontFamily: icon.icon!.fontFamily,
          color: icon.color ?? Colors.black,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (markerSize - textPainter.width) / 2,
        (markerSize - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(markerSize.toInt(), markerSize.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable them.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      _addUserMarker();
      _loadVendorMarkers();
    } catch (e) {
      throw 'Failed to get current location: $e';
    }
  }

  void _addUserMarker() {
    if (_currentPosition == null) return;

    final userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'You are here'),
    );

    setState(() {
      _markers.add(userMarker);
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      ),
    );
  }

  void _loadVendorMarkers() {
    for (var vendor in _vendors) {
      final marker = Marker(
        markerId: MarkerId(vendor['name']),
        position: LatLng(vendor['latitude'], vendor['longitude']),
        icon: _shoppingCartIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: vendor['name']),
        onTap: () => _navigateToVendorDetails(vendor),
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  void _navigateToVendorDetails(Map<String, dynamic> vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorDetailsPage(vendorName: vendor['name']),
      ),
    );
  }

  void _filterVendors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVendors = _vendors;
        _showSuggestions = false;
      } else {
        _filteredVendors = _vendors
            .where((vendor) => vendor['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showSuggestions = true;
      }
    });
  }

  void _selectVendor(Map<String, dynamic> vendor) {
    final marker = Marker(
      markerId: MarkerId(vendor['name']),
      position: LatLng(vendor['latitude'], vendor['longitude']),
      icon: _shoppingCartIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: vendor['name']),
      onTap: () => _navigateToVendorDetails(vendor),
    );

    setState(() {
      _markers.clear();
      _addUserMarker();
      _markers.add(marker);
      _searchController.text = vendor['name'];
      _showSuggestions = false;
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(vendor['latitude'], vendor['longitude']),
        16.0,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Map",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Vendors...',
                    hintStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[700],
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterVendors,
                ),
                if (_showSuggestions)
                  Container(
                    color: Colors.grey[600],
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredVendors.length,
                      itemBuilder: (context, index) {
                        final vendor = _filteredVendors[index];
                        return ListTile(
                          title: Text(vendor['name'], style: TextStyle(color: Colors.white)),
                          onTap: () => _selectVendor(vendor),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentPosition == null
                ? const Center(
              child: Text(
                'Unable to fetch location. Please try again.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
                : GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController.setMapStyle(_darkMapStyle);
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 16.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

