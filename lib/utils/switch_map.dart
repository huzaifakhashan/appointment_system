import 'dart:async';

extension SwitchMap<T> on Stream<T> {
  /// Maps each event to a new stream and forwards only the latest one.
  ///
  /// Unlike [asyncExpand], which waits for the previous inner stream to
  /// finish before handling the next event, this cancels it right away. That
  /// matters for Firestore listeners, which never finish on their own: with
  /// [asyncExpand], a sign-out event would wait behind the old user's profile
  /// listener forever and never arrive.
  Stream<R> switchMap<R>(Stream<R> Function(T event) convert) {
    StreamSubscription<T>? outer;
    StreamSubscription<R>? inner;
    late final StreamController<R> controller;
    controller = StreamController<R>(
      onListen: () {
        outer = listen(
          (event) {
            inner?.cancel();
            inner = convert(event).listen(controller.add, onError: controller.addError);
          },
          onError: controller.addError,
          onDone: () async {
            await inner?.cancel();
            await controller.close();
          },
        );
      },
      onCancel: () async {
        await inner?.cancel();
        await outer?.cancel();
      },
    );
    return controller.stream;
  }
}
