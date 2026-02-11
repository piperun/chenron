import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:app_logger/app_logger.dart";

import "package:chenron/features/settings/service/data_settings_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    loggerGlobal.setupLogging(logDir: Directory.systemTemp);
  });

  group("getCustomDatabasePath", () {
    test("returns null when no path is stored", () async {
      SharedPreferences.setMockInitialValues({});
      final service = DataSettingsService();

      final result = await service.getCustomDatabasePath();

      expect(result, isNull);
    });

    test("returns stored path", () async {
      SharedPreferences.setMockInitialValues({
        "app_database_path": "/custom/db/path",
      });
      final service = DataSettingsService();

      final result = await service.getCustomDatabasePath();

      expect(result, "/custom/db/path");
    });
  });

  group("setCustomDatabasePath", () {
    test("stores a custom path", () async {
      SharedPreferences.setMockInitialValues({});
      final service = DataSettingsService();

      await service.setCustomDatabasePath("/my/custom/path");

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("app_database_path"), "/my/custom/path");
    });

    test("removes path when set to null", () async {
      SharedPreferences.setMockInitialValues({
        "app_database_path": "/old/path",
      });
      final service = DataSettingsService();

      await service.setCustomDatabasePath(null);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("app_database_path"), isNull);
    });

    test("overwrites existing path", () async {
      SharedPreferences.setMockInitialValues({
        "app_database_path": "/old/path",
      });
      final service = DataSettingsService();

      await service.setCustomDatabasePath("/new/path");

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("app_database_path"), "/new/path");
    });
  });

  group("round-trip", () {
    test("set then get returns same value", () async {
      SharedPreferences.setMockInitialValues({});
      final service = DataSettingsService();

      await service.setCustomDatabasePath("/round/trip");
      final result = await service.getCustomDatabasePath();

      expect(result, "/round/trip");
    });

    test("set null then get returns null", () async {
      SharedPreferences.setMockInitialValues({
        "app_database_path": "/something",
      });
      final service = DataSettingsService();

      await service.setCustomDatabasePath(null);
      final result = await service.getCustomDatabasePath();

      expect(result, isNull);
    });
  });
}
