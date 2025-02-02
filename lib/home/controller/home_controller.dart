import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable selected index
  var selectedIndex = 0.obs;

  // Update the selected index
  void updateIndex(int index) {
    selectedIndex.value = index;
  }
}
