import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import '../controller/map_controller.dart';

getAddress() async {
  MapController controller = Get.put(MapController());
  try {
    List<Placemark> area = await placemarkFromCoordinates(
        controller.currentPosition.latitude,
        controller.currentPosition.longitude);

    Placemark place = area[0];

    controller.currentAdd.value = place.locality!;
    controller.startAddressController.text = controller.currentAdd.value;
    controller.startAddress.value = controller.currentAdd.value;
  } catch (e) {
    print(e);
  }
}
