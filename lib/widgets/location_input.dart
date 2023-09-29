import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:screenshot/screenshot.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  double lat = 0;
  double lng = 0;
  final List<Marker> _markers = [];
  String _address = '';
  LatLng? _selectedLocation;

  // String get locationImage {
  //   if (_pickedLocation == null) {
  //     return '';
  //   }

  //   final lat = _pickedLocation!.latitude;
  //   final lng = _pickedLocation!.longitude;

  //   return "https://maps.googleapis.com/maps/api/staticmap?center$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=API-KEY";
  // }

  void _addMarker(LatLng point) {
    setState(() {
      _selectedLocation = point;
      _markers.clear();
      _markers.add(Marker(
        width: 40.0,
        height: 40.0,
        point: point,
        builder: (ctx) => Container(
          child: const Icon(
            Icons.location_on,
            size: 40.0,
            color: Colors.red,
          ),
        ),
      ));
    });
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        "https://api.opencagedata.com/geocode/v1/json?q=$lat+$lng&key=e8b83756b5744b0c96fea3d8468dfe10");

    final response = await http.get(url);

    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted'];
    print("address: $address");
    setState(() {
      _pickedLocation = PlaceLocation(
          latitude: latitude, longitude: longitude, address: address);
      _isGettingLocation = false;
      _address = address;
    });
    _addMarker(LatLng(lat, lng));

    widget.onSelectLocation(_pickedLocation!);
  }

  Widget _locationImage(
      ScreenshotController screenshotController, PlaceLocation place) {
    return Screenshot(
        controller: screenshotController,
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(
                place.latitude, place.longitude), // Initial map coordinates
            zoom: 12.0, // Zoom level
            // onTap: _addMarker,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: _markers),
          ],
        ));
  }

  void _getCurrentLocation() async {
    final image = await _screenshotController.capture();
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    lat = locationData.latitude!;
    lng = locationData.longitude!;

    if (lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      "No location chosen!",
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );

    if (_pickedLocation != null) {
      previewContent = _locationImage(_screenshotController, _pickedLocation!);
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
            height: 170,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2))),
            child: previewContent),
        const SizedBox(
          height: 10,
        ),
        Text(
          _address == ""
              ? _address
              : _address[0].toUpperCase() + _address.substring(1),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text("Get Current Location"),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("Select on Map"),
              onPressed: () {},
            )
          ],
        )
      ],
    );
  }
}
