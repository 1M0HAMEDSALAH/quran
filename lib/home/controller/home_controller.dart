import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  final RxBool isNavBarVisible = true.obs;
  double lastScrollPosition = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    final currentScrollPosition = scrollController.position.pixels;
    
    if (currentScrollPosition > lastScrollPosition && currentScrollPosition > 50) {
      // Scrolling down
      if (isNavBarVisible.value) {
        isNavBarVisible.value = false;
      }
    } else if (currentScrollPosition < lastScrollPosition && isNavBarVisible.value == false) {
      // Scrolling up
      isNavBarVisible.value = true;
    }
    
    lastScrollPosition = currentScrollPosition;
  }

  void updateIndex(int index) {
    selectedIndex.value = index;
  }
}
