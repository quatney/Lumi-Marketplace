import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/pages/store_main_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => const StoreMainPage(),
    };
  }
}
