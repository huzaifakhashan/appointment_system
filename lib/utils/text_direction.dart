/// Wraps [text] so it always reads left-to-right, even inside Arabic text —
/// for phone numbers, which would otherwise show the "+" at the wrong end.
String ltr(String text) => '$_ltrIsolate$text$_popIsolate';

// Unicode "left-to-right isolate" and "pop directional isolate". Built from
// their code points so the source has no invisible characters in it.
final _ltrIsolate = String.fromCharCode(0x2066);
final _popIsolate = String.fromCharCode(0x2069);
