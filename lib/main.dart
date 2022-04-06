import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'controller/map_controller.dart';
import 'map_data/distance.dart';
import 'map_data/address.dart';
import 'widget/textform.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController controller = Get.put(MapController());

  // Method for retrieving the current location
  currentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        controller.currentPosition = position;
        controller.mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      });

      await getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address

  @override
  void initState() {
    super.initState();
    currentLocation();
    controller.destinationAddressController.text = 'cuddalore';
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(body: Obx(() {
      return Stack(
        children: <Widget>[
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                child: ClipOval(
                  child: Material(
                    color: Color.fromARGB(255, 10, 6, 1), // button color
                    child: InkWell(
                      splashColor: Colors.orange, // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.my_location),
                      ),
                      onTap: () {
                        controller.mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                controller.currentPosition.latitude,
                                controller.currentPosition.longitude,
                              ),
                              zoom: 5.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Map View
          GoogleMap(
            markers: Set<Marker>.from(controller.markers),
            initialCameraPosition: controller.initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: Set<Polyline>.of(controller.polylines.values),
            onMapCreated: (GoogleMapController controller1) {
              controller.mapController = controller1;
            },
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                child: ClipOval(
                  clipBehavior: Clip.hardEdge,
                  child: Material(
                    color: Color.fromARGB(255, 243, 238, 231), // button color
                    child: InkWell(
                      splashColor: Colors.orange, // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.my_location),
                      ),
                      onTap: () {
                        currentLocation();
                        controller.mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                controller.currentPosition.latitude,
                                controller.currentPosition.longitude,
                              ),
                              zoom: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 10),
                        textField(
                            label: 'Start',
                            hint: 'Choose starting point',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.my_location),
                              onPressed: () {
                                currentLocation();
                                controller.mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        controller.currentPosition.latitude,
                                        controller.currentPosition.longitude,
                                      ),
                                      zoom: 18.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                            controller: controller.startAddressController,
                            focusNode: controller.startAddressFocusNode,
                            width: width,
                            locationCallback: (String value) {
                              setState(() {
                                controller.startAddress.value = value;
                              });
                            }),
                        SizedBox(height: 10),
                        textField(
                            label: 'Destination',
                            hint: 'Choose destination',
                            controller: controller.destinationAddressController,
                            focusNode: controller.desrinationAddressFocusNode,
                            width: width,
                            locationCallback: (String value) {
                              setState(() {
                                controller.destinationAddressController.text =
                                    value;
                              });
                            }),
                        SizedBox(height: 10),
                        Visibility(
                          visible: controller.placeDistance.value == ''
                              ? false
                              : true,
                          child: Text(
                            'DISTANCE: ${controller.placeDistance.value.toString()} KM',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: (controller.startAddress.value != '')
                              ? () async {
                                  controller.startAddressFocusNode.unfocus();
                                  controller.desrinationAddressFocusNode
                                      .unfocus();
                                  calculateDistance();
                                  setState(() {});
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Show directions'.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }));
  }
}
