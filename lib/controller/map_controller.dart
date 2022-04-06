import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  late Position currentPosition;
  RxString currentAdd = ''.obs;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  RxString startAddress = ''.obs;
  RxString placeDistance = ''.obs;

  Set<Marker> markers = {};

  CameraPosition initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  late GoogleMapController mapController;
  // ignore: non_constant_identifier_names
  String api = 'AIzaSyD789ejb86QhaIBRPovLCtjW_XrrDAKdto';
}
