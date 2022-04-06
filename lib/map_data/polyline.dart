import 'package:flutter/material.dart';
import 'package:flutter_maps/controller/map_controller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

createPolylines(
  double startLatitude,
  double startLongitude,
  double destinationLatitude,
  double destinationLongitude,
) async {
  MapController controller = Get.put(MapController());
  controller.polylinePoints = PolylinePoints();
  PolylineResult result =
      await controller.polylinePoints.getRouteBetweenCoordinates(
    controller.api, // Google Maps API Key
    PointLatLng(startLatitude, startLongitude),
    PointLatLng(destinationLatitude, destinationLongitude),
    travelMode: TravelMode.driving,
  );

  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      controller.polylineCoordinates
          .add(LatLng(point.latitude, point.longitude));
    });
  }

  PolylineId id = PolylineId('poly');
  Polyline polyline = Polyline(
    polylineId: id,
    width: 5,
    color: Colors.red,
    points: controller.polylineCoordinates,
  );
  controller.polylines[id] = polyline;
}
