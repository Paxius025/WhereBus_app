// lib/widgets/static/location_map/buses.dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

List<Marker> getStaticBusMarkers(MapController mapController) {
  return [
    Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(17.289014, 104.111125), // Bus ID 2 (Offline)
      builder: (ctx) {
        double zoom = mapController.zoom;
        double iconSize = 20.0 * (zoom / 14); // Adjust icon size based on zoom
        double textSize = 10.0 * (zoom / 14); // Adjust text size based on zoom

        return Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.red,
              size: iconSize,
            ),
            Text(
              'Bus 2',
              style: TextStyle(
                color: Colors.black,
                fontSize: textSize,
              ),
            ),
          ],
        );
      },
    ),
    Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(17.287491, 104.112630), // Bus 3 (Online)
      builder: (ctx) {
        double zoom = mapController.zoom;
        double iconSize = 20.0 * (zoom / 14);
        double textSize = 10.0 * (zoom / 14);

        return Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.green,
              size: iconSize,
            ),
            Text(
              'Bus 3',
              style: TextStyle(
                color: Colors.black,
                fontSize: textSize,
              ),
            ),
          ],
        );
      },
    ),
    Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(17.288904, 104.107397), // Bus ID 4 (Online)
      builder: (ctx) {
        double zoom = mapController.zoom;
        double iconSize = 20.0 * (zoom / 14);
        double textSize = 10.0 * (zoom / 14);

        return Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.green,
              size: iconSize,
            ),
            Text(
              'Bus 4',
              style: TextStyle(
                color: Colors.black,
                fontSize: textSize,
              ),
            ),
          ],
        );
      },
    ),
  ];
}
