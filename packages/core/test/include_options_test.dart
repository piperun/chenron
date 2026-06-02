import "package:core/patterns/include_options.dart";
import "package:flutter_test/flutter_test.dart";

enum _Feature { alpha, beta, gamma }

void main() {
  group("IncludeOptions", () {
    test("has() reports membership", () {
      const options = IncludeOptions<_Feature>({_Feature.alpha, _Feature.beta});

      expect(options.has(_Feature.alpha), isTrue);
      expect(options.has(_Feature.beta), isTrue);
      expect(options.has(_Feature.gamma), isFalse);
    });

    test("empty() contains nothing", () {
      const options = IncludeOptions<_Feature>.empty();

      expect(options.has(_Feature.alpha), isFalse);
      expect(options.options, isEmpty);
    });
  });

  group("IncludeOptions.unmodifiable", () {
    test("rejects mutation of the wrapped set", () {
      final options =
          IncludeOptions<_Feature>.unmodifiable({_Feature.alpha});

      expect(() => options.options.add(_Feature.beta),
          throwsA(isA<UnsupportedError>()));
      expect(() => options.options.remove(_Feature.alpha),
          throwsA(isA<UnsupportedError>()));
      expect(() => options.options.clear(),
          throwsA(isA<UnsupportedError>()));
    });

    test("still answers has() correctly", () {
      final options = IncludeOptions<_Feature>.unmodifiable(
          {_Feature.alpha, _Feature.gamma});

      expect(options.has(_Feature.alpha), isTrue);
      expect(options.has(_Feature.beta), isFalse);
      expect(options.has(_Feature.gamma), isTrue);
    });

    test("is a view, not a defensive copy: source mutations show through", () {
      // UnmodifiableSetView wraps the provided set rather than copying it, so
      // mutating the original source is still observable through the view. The
      // constructor blocks mutation *through* IncludeOptions, not mutation of
      // the caller's original set. Callers needing a frozen snapshot must pass
      // a fresh set they no longer hold a reference to.
      final source = {_Feature.alpha};
      final options = IncludeOptions<_Feature>.unmodifiable(source);

      expect(options.has(_Feature.beta), isFalse);
      source.add(_Feature.beta);
      expect(options.has(_Feature.beta), isTrue);
    });
  });
}
