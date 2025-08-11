// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:streamit_flutter/utils/common.dart';

void main() {
  group('getVideoLink', () {
    test('returns the video link when given valid HTML data', () {
      // Arrange
      final htmlData = '<html><body><iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ"></iframe></body></html>';

      // Act
      final result = getVideoLink(htmlData);

      // Assert
      expect(result, equals('https://www.youtube.com/embed/dQw4w9WgXcQ'));
    });

    test('returns an empty string when no iframe is found', () {
      // Arrange
      final htmlData = '<html><body><div>Some text</div></body></html>';

      // Act
      final result = getVideoLink(htmlData);

      // Assert
      expect(result, isEmpty);
    });

    test('returns an empty string when the iframe src attribute is missing', () {
      // Arrange
      final htmlData = '<html><body><iframe></iframe></body></html>';

      // Act
      final result = getVideoLink(htmlData);

      // Assert
      expect(result, isEmpty);
    });
  });
}
