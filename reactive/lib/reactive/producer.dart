import 'codec.dart';
import 'constants.dart';
import 'requester.dart';

class ReactiveProducer {
  final ReactiveRequester _requester;
  final ReactiveCodec _codec;

  const ReactiveProducer(this._requester, this._codec);

  @inline
  void payload(dynamic data, {bool complete = false}) => _requester.schedulePayload(_codec.encode(data), complete);

  @inline
  void error(String message) => _requester.scheduleError(message);

  @inline
  void cancel() => _requester.scheduleCancel();

  @inline
  void complete() => _requester.schedulePayload(emptyBytes, true);

  @inline
  void request(int count) => _requester.request(count);

  @inline
  void unbound() => _requester.request(reactiveInfinityRequestsCount);
}
