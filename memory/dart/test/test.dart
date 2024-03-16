
import 'package:memory/memory.dart';

void main(List<String> args) {
  SystemEnvironment.debug = true;
  launch((creator) => creator.create(CoreModule(), CoreDefaults.module).create(MemoryModule(), MemoryDefaults.module)).activate(() {
    final data = [123];
    final sw = Stopwatch();
    final stream = context().tuples().dynamic.output();
    sw.start();
    for (var i = 0; i < 100000000; i++) {
      stream.writeList(data.length);
      stream.writeInt(data[0]);
    }
    stream.flush();
    print(sw.elapsed.inMilliseconds);
    stream.destroy();
  });
}
