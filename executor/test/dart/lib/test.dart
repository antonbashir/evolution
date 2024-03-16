import 'package:test/test.dart';

import 'test/call.dart';
import 'test/threading.dart';

void main() {
  group("[call native]", testCallNative);
  group("[call dart]", testCallDart);
  group("[threading native]", testThreadingNative);
  // group("[threading dart]", testThreadingDart);
}
