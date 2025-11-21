import "dart:io";

/// Runs the Monolith CLI tool.
class MonolithRunner {
  /// Path to the Monolith executable.
  String? executablePath = "monolith";

  /// Creates a new [MonolithRunner].
  MonolithRunner({this.executablePath});

  /// Runs Monolith to archive the given [url].
  Future<String> run(
    String url, {
    bool noAudio = false,
    bool noFrames = false,
    bool noVideo = false,
    bool noJs = false,
    bool noImages = false,
    bool ignoreErrors = true,
    String output = "",
  }) async {
    executablePath ??= "monolith";
    final args = [url];
    if (noAudio) args.add("--no-audio");
    if (noFrames) args.add("--no-frames");
    if (noVideo) args.add("--no-video");
    if (noJs) args.add("--no-js");
    if (noImages) args.add("--no-images");
    if (ignoreErrors) args.add("--ignore-errors");
    if (output.isNotEmpty) args.addAll(["-o", output]);

    final result = await Process.run(executablePath!, args);

    if (result.exitCode != 0) {
      throw Exception("Monolith failed: ${result.stderr}");
    }

    return result.stdout as String;
  }
}
