import "dart:io";
import "dart:ui";

import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:app_logger/app_logger.dart";
import "package:chenron/services/window_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    loggerGlobal.setupLogging(logDir: Directory.systemTemp);
  });

  group("WindowService", () {
    group("getSavedWindowSize", () {
      test("returns null when no size is stored", () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = WindowService(prefs);

        expect(service.getSavedWindowSize(), isNull);
      });

      test("returns null when only width is stored", () async {
        SharedPreferences.setMockInitialValues({"window_width": 1024.0});
        final prefs = await SharedPreferences.getInstance();
        final service = WindowService(prefs);

        expect(service.getSavedWindowSize(), isNull);
      });

      test("returns null when only height is stored", () async {
        SharedPreferences.setMockInitialValues({"window_height": 768.0});
        final prefs = await SharedPreferences.getInstance();
        final service = WindowService(prefs);

        expect(service.getSavedWindowSize(), isNull);
      });

      test("returns saved size when both are stored", () async {
        SharedPreferences.setMockInitialValues({
          "window_width": 1600.0,
          "window_height": 900.0,
        });
        final prefs = await SharedPreferences.getInstance();
        final service = WindowService(prefs);

        final size = service.getSavedWindowSize();
        expect(size, isNotNull);
        expect(size!.width, 1600.0);
        expect(size.height, 900.0);
      });
    });

    group("saveWindowSize", () {
      test("persists width and height", () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = WindowService(prefs);

        await service.saveWindowSize(const Size(1920, 1080));

        expect(prefs.getDouble("window_width"), 1920.0);
        expect(prefs.getDouble("window_height"), 1080.0);
      });

      test("overwrites previous values", () async {
        SharedPreferences.setMockInitialValues({
          "window_width": 800.0,
          "window_height": 600.0,
        });
        final prefs = await SharedPreferences.getInstance();
        final service = WindowService(prefs);

        await service.saveWindowSize(const Size(1280, 720));

        expect(prefs.getDouble("window_width"), 1280.0);
        expect(prefs.getDouble("window_height"), 720.0);
      });
    });
  });

  group("WindowService.computeTargetSize", () {
    const screen = Size(1920, 1080);

    test("returns 80% of screen when no saved size", () {
      final result = WindowService.computeTargetSize(
        savedSize: null,
        screenSize: screen,
      );

      expect(result.width, 1920 * 0.8);
      expect(result.height, 1080 * 0.8);
    });

    test("returns saved size when within bounds", () {
      final result = WindowService.computeTargetSize(
        savedSize: const Size(1280, 720),
        screenSize: screen,
      );

      expect(result.width, 1280);
      expect(result.height, 720);
    });

    test("clamps width to screen when saved is too wide", () {
      final result = WindowService.computeTargetSize(
        savedSize: const Size(2560, 720),
        screenSize: screen,
      );

      expect(result.width, 1920);
      expect(result.height, 720);
    });

    test("clamps height to screen when saved is too tall", () {
      final result = WindowService.computeTargetSize(
        savedSize: const Size(1280, 1440),
        screenSize: screen,
      );

      expect(result.width, 1280);
      expect(result.height, 1080);
    });

    test("clamps to minimum when saved is too small", () {
      final result = WindowService.computeTargetSize(
        savedSize: const Size(100, 50),
        screenSize: screen,
      );

      expect(result.width, 400);
      expect(result.height, 300);
    });

    test("clamps both dimensions on smaller screen", () {
      final result = WindowService.computeTargetSize(
        savedSize: const Size(1920, 1080),
        screenSize: const Size(1366, 768),
      );

      expect(result.width, 1366);
      expect(result.height, 768);
    });
  });
}
