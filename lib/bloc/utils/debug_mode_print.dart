import 'package:flutter/foundation.dart';

void logPrint(String s) {
  if (kDebugMode) {
    print(s);
  }
}