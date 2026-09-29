import 'dart:async';

import 'package:appointment_system/utils/switch_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mimics the profile stream: auth events (a uid, or null when signed out),
/// each mapped to a Firestore-like listener that never completes.
void main() {
  Stream<String?> profileFor(String? uid) =>
      uid == null ? Stream.value(null) : _neverEnding('profile of $uid');

  test('sign-out gets through while the old listener is still open', () async {
    final auth = StreamController<String?>();
    final seen = <String?>[];
    final sub = auth.stream.switchMap(profileFor).listen(seen.add);

    auth.add('u1');
    await _pump();
    auth.add(null); // sign out
    await _pump();

    expect(seen, ['profile of u1', null]);
    await sub.cancel();
  });

  test('asyncExpand (the old code) never delivers the sign-out', () async {
    final auth = StreamController<String?>();
    final seen = <String?>[];
    final sub = auth.stream.asyncExpand(profileFor).listen(seen.add);

    auth.add('u1');
    await _pump();
    auth.add(null);
    await _pump();

    expect(seen, ['profile of u1']); // stuck: the bug that was fixed
    await sub.cancel();
  });

  test('cancelling the result cancels the inner listener', () async {
    var innerCancelled = false;
    final inner = StreamController<int>(onCancel: () => innerCancelled = true);
    final sub = Stream.value(1).switchMap((_) => inner.stream).listen((_) {});
    await _pump();
    await sub.cancel();
    expect(innerCancelled, isTrue);
  });
}

Stream<String?> _neverEnding(String value) {
  final c = StreamController<String?>();
  c.add(value);
  return c.stream; // never closed, like a Firestore snapshots() stream
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);
