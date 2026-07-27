// Basic smoke test placeholder for Daily English.
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_english/speech.dart';

void main() {
  test('pronunciation score is 100 for an exact match', () {
    expect(Speech.score('hello world', 'Hello, World!'), 100);
  });
}
