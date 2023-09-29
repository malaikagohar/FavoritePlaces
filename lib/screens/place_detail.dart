import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:screenshot/screenshot.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final List<Marker> _markers = [];
  LatLng? _selectedLocation;
  final ScreenshotController _screenshotController = ScreenshotController();

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

  Widget _locationImage(
      ScreenshotController screenshotController, PlaceLocation place) {
    _addMarker(LatLng(place.latitude, place.longitude));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.place.title)),
        body: Stack(
          children: [
            Image.file(
              widget.place.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      height: 160,
                      width: 160,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // borderRadius: BorderRadius.circular(100),
                      ),
                      child: _locationImage(
                          _screenshotController, widget.place.location),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black54],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Text(
                        widget.place.location.address[0].toUpperCase() +
                            widget.place.location.address.substring(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color:
                                    Theme.of(context).colorScheme.background),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
