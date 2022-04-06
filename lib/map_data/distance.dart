import 'package:flutter_maps/controller/map_controller.dart';
import 'package:flutter_maps/map_data/polyline.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<bool> calculateDistance() async {
  MapController controller = Get.put(MapController());
  try {
    List<Location> startPlacemark =
        await locationFromAddress(controller.startAddress.value);
    List<Location> destinationPlacemark =
        await locationFromAddress(controller.destinationAddressController.text);
    double startLatitude = controller.startAddress == controller.currentAdd
        ? controller.currentPosition.latitude
        : startPlacemark[0].latitude;

    double startLongitude = controller.startAddress == controller.currentAdd
        ? controller.currentPosition.longitude
        : startPlacemark[0].longitude;

    double destinationLatitude = destinationPlacemark[0].latitude;
    double destinationLongitude = destinationPlacemark[0].longitude;

    String startCoordinatesString = '($startLatitude, $startLongitude)';
    String destinationCoordinatesString =
        '($destinationLatitude, $destinationLongitude)';

    Marker startMarker = Marker(
      markerId: MarkerId(startCoordinatesString),
      position: LatLng(startLatitude, startLongitude),
      icon: BitmapDescriptor.defaultMarker,
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId(destinationCoordinatesString),
      position: LatLng(destinationLatitude, destinationLongitude),
      icon: BitmapDescriptor.defaultMarker,
    );

    controller.markers.add(startMarker);
    controller.markers.add(destinationMarker);

    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    controller.mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

    await createPolylines(startLatitude, startLongitude, destinationLatitude,
        destinationLongitude);

    final value = Geolocator.distanceBetween(startLatitude, startLongitude,
        destinationLatitude, destinationLongitude);

    controller.placeDistance.value = (value ~/ 1000).toString();

    return true;
  } catch (e) {
    print(e);
  }
  return false;
}
