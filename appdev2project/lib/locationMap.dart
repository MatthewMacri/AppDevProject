import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customDrawer.dart';


class MyMap extends StatefulWidget {
  String docId;

  MyMap(this.docId);
  @override
  _MyMapState createState() => _MyMapState(docId);
}

class _MyMapState extends State<MyMap> {
  String docId;

  _MyMapState(this.docId);

  late GoogleMapController mapController;

  LatLng? _source;
  final LatLng _destination = LatLng(45.464008, -73.831421);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  String _durationText = '';
  String _selectedMode = 'driving';

  String fullName = " ";
  String userType = "";
  String status = "";
  DateTime expireDate = DateTime.now();
  int daysTillExpired = 0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      Map<String, dynamic> userData =
      snapshot.data() as Map<String, dynamic>;

      int daysLeft = 0;
      DateTime expDate = DateTime.now();

      userType = userData['type'];
      if(userType == "member") {
        expDate = (userData['expireDate'] as Timestamp).toDate();
        daysLeft = expDate.difference(DateTime.now()).inDays;
        daysLeft = (daysLeft < 0) ? 0 : daysLeft;
      }

      setState(() {
        fullName = userData['fullName'];
        userType = userData['type'];
        status = userData['status'];
        expireDate = expDate;
        daysTillExpired = daysLeft;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permission not granted');
      }
    }

    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _source = LatLng(position.latitude, position.longitude);
      _addMarkers();
      _getDirections(_selectedMode);
    });
  }

  void _addMarkers() {
    if (_source == null) return;
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId('source'),
      position: _source!,
      infoWindow: InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
    _markers.add(Marker(
      markerId: MarkerId('destination'),
      position: _destination,
      infoWindow: InfoWindow(title: 'Gym'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  Future<void> _getDirections(String mode) async {
    if (_source == null) return;

    final String apiKey = 'You API Key';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_source!.latitude},${_source!.longitude}&destination=${_destination.latitude},${_destination.longitude}&mode=$mode&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isEmpty) {
        setState(() {
          _durationText = 'Duration: N/A';
          _polylines.clear();
        });
        return;
      }

      final duration = data['routes'][0]['legs'][0]['duration']['text'];
      final overviewPolyline = data['routes'][0]['overview_polyline']['points'];

      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> result = polylinePoints.decodePolyline(overviewPolyline);

      _polylineCoordinates.clear();
      _polylineCoordinates.addAll(result.map((e) => LatLng(e.latitude, e.longitude)));

      setState(() {
        _selectedMode = mode;
        _durationText = ' Duration: $duration';
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToPolyline());
    } else {
      print('Failed to fetch directions: ${response.statusCode}');
      setState(() {
        _durationText = ' Duration: Error';
        _polylines.clear();
      });
    }
  }

  void _fitMapToPolyline() {
    if (_polylineCoordinates.isEmpty) return;

    double minLat = _polylineCoordinates.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = _polylineCoordinates.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = _polylineCoordinates.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = _polylineCoordinates.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Widget _buildModeButton(String mode, String label) {
    bool isSelected = _selectedMode == mode;
    return ElevatedButton(
      onPressed: () => _getDirections(mode),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
      ),
      child: Text(
        '$label',
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Directions to the gym'),
          backgroundColor: Colors.blue,
        ),
        body: _source == null
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeButton('driving', 'Drive'),
                  _buildModeButton('walking', 'Walk'),
                  _buildModeButton('bicycling', 'Bike'),
                ],
              ),
            ),
            if (_durationText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _durationText,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              Row( mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 30),
                  SizedBox(width: 4),
                  Text('Your Location  ', style: TextStyle(fontSize: 20)),
                  Icon(Icons.location_on, color: Colors.red, size: 30),
                  SizedBox(width: 4),
                  Text('Gym', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Expanded(
                child: GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    if (_polylineCoordinates.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToPolyline());
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _source ?? LatLng(0, 0),
                    zoom: 1, // Very zoomed out
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                )
            ),
          ],
        ),
        drawer: AppDrawer(
          docId: widget.docId,
          userRole: userType,
          fullName: fullName,
          status: status,
          daysTillExpired: daysTillExpired,
          expireDate: expireDate,
        ),

      ),
    );
  }
}