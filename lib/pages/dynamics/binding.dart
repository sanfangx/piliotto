import 'package:get/get.dart';

import 'controller.dart';

class DynamicsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DynamicsController());
  }
}
