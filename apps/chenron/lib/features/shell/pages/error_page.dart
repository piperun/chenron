// --- Fallback Error App --- (Optional, but good practice)
import "package:flutter/material.dart";

class ErrorApp extends StatelessWidget {
  final Object error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    // Use Flutter's default themes for the fallback error display
    // to ensure it works even if custom themes fail to load.
    return MaterialApp(
      theme: ThemeData.light(), // Use default light theme
      darkTheme: ThemeData.dark(), // Use default dark theme
      themeMode: ThemeMode.system, // Respect system setting for the error page
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48.0),
                const SizedBox(height: 16.0),
                Text(
                  "Fatal Error During Startup",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Error Type: ${error.runtimeType}\n\nDetails: $error",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Please check logs or restart the application.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

