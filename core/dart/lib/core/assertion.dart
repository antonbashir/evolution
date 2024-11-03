bool assertTrue(void Function() action) {
  assert(() {
    action();
    return true;
  }());
  return true;
}
