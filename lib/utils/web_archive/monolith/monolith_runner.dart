import 'dart:io';

class MonolithRunner {
  final String executablePath;

  MonolithRunner(this.executablePath);

  Future<String> run(
    String url, {
    bool noAudio = false,
    bool noFrames = false,
    bool noVideo = false,
    bool noJs = false,
    bool noImages = false,
    String output = '',
  }) async {
    final args = [url];

    if (noAudio) args.add('--no-audio');
    if (noFrames) args.add('--no-frames');
    if (noVideo) args.add('--no-video');
    if (noJs) args.add('--no-js');
    if (noImages) args.add('--no-images');
    if (output.isNotEmpty) args.addAll(['-o', output]);

    final result = await Process.run(executablePath, args);

    if (result.exitCode != 0) {
      throw Exception('Monolith failed: ${result.stderr}');
    }

    return result.stdout;
  }
}
