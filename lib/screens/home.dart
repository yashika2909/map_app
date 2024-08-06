import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(28.6304, 77.3721), zoom: 14);

  final Set<Marker> marker = {
    const Marker(
      markerId: MarkerId('4'),
      position: LatLng(28.6304, 77.3721),
      icon: BitmapDescriptor.defaultMarker,
    )
  };
  final Set<Polyline> polyLine = {};
  final latlng = <LatLng>[
    const LatLng(28.5974, 77.3827),
    const LatLng(28.572399, 77.335480),
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < latlng.length; i++) {
      marker.add(Marker(
        markerId: MarkerId(i.toString()),
        position: latlng[i],
        icon: BitmapDescriptor.defaultMarker,
      ));
      setState(() {});
      polyLine.add(
        Polyline(
            polylineId: const PolylineId('1'),
            points: latlng,
            color: Colors.blue),
      );
    }
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){

    }).onError((error, stackTrace) {
      print("error" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: _kGooglePlex,
          markers: Set<Marker>.of(marker),
          mapType: MapType.normal,
          compassEnabled: false,
          myLocationEnabled: true,
          polylines: polyLine,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_disabled_outlined),
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            print('current location');
            print(value.latitude.toString() + " " + value.longitude.toString());
            marker.add(
              Marker(
                  markerId: const MarkerId('3'),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: const InfoWindow(title: 'My current location')),
            );
            CameraPosition cameraPosition = CameraPosition(
                zoom: 14, target: LatLng(value.latitude, value.longitude));
            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
      ),
    );
  }
}
