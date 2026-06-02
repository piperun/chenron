import "package:flutter_test/flutter_test.dart";
import "package:platform_provider/platform_provider.dart";

/// Minimal stand-in OS so tests can drive platform-dependent code paths
/// without being pinned to the host the suite happens to run on.
class _FakeOS extends OperatingSystem {
  @override
  bool get isDesktop => true;
  @override
  bool get isMobile => false;
  @override
  String get name => "FakeOS";
  @override
  PlatformResources get resources => _FakeResources();
}

class _FakeResources extends PlatformResources {
  @override
  String get cacheDirectoryHint => "/fake/cache";
  @override
  String get monolithExecutableName => "fake-monolith";
}

void main() {
  tearDown(OperatingSystem.resetForTesting);

  group("OperatingSystem testability", () {
    test("current returns an injected fake OS", () {
      OperatingSystem.current = _FakeOS();

      final os = OperatingSystem.current;
      expect(os, isA<_FakeOS>());
      expect(os.name, "FakeOS");
      expect(os.isDesktop, isTrue);
      expect(os.resources.monolithExecutableName, "fake-monolith");
    });

    test("resetForTesting clears the injected OS and re-resolves", () {
      OperatingSystem.current = _FakeOS();
      expect(OperatingSystem.current.name, "FakeOS");

      OperatingSystem.resetForTesting();

      // After reset, the real host OS resolves — definitely not the fake.
      expect(OperatingSystem.current, isNot(isA<_FakeOS>()));
      expect(OperatingSystem.current.name, isNot("FakeOS"));
    });

    test("injection is stable across repeated reads", () {
      OperatingSystem.current = _FakeOS();
      final first = OperatingSystem.current;
      final second = OperatingSystem.current;
      expect(identical(first, second), isTrue);
    });
  });
}
