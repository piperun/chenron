import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

final easiest = signal(getA());

Future<ThemeMode> getA() async {
  final great = await locator
      .get<ConfigDatabaseFileHandler>()
      .configDatabase
      .getUserConfig();

  return great!.data.darkMode ? ThemeMode.dark : ThemeMode.light;
}
