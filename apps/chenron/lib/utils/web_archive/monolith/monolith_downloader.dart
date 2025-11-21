import "dart:convert";
import "dart:io";
import "package:http/http.dart" as http;
import "package:path_provider/path_provider.dart";
import "package:platform_provider/platform_provider.dart";

class MonolithDownloader {
  static Future<String> downloadLatestRelease() async {
    const githubApiUrl =
        "https://api.github.com/repos/Y2Z/monolith/releases/latest";
    final response = await http.get(Uri.parse(githubApiUrl));

    if (response.statusCode == 200) {
      final releaseData = json.decode(response.body);
      final assets = releaseData["assets"] as List;

      if (!OperatingSystem.current.isDesktop) {
        throw UnsupportedError("Unsupported platform");
      }
      final assetName =
          OperatingSystem.current.resources.monolithExecutableName;

      final asset = assets.firstWhere((a) => a["name"] == assetName);
      final downloadUrl = asset["browser_download_url"] as String;

      final appDir = await getApplicationDocumentsDirectory();
      final savePath = "${appDir.path}/chenron/$assetName";

      await Directory("${appDir.path}/chenron").create(recursive: true);

      final exeFile = File(savePath);
      await exeFile.writeAsBytes(await http.readBytes(Uri.parse(downloadUrl)));

      return savePath;
    } else {
      throw Exception("Failed to download Monolith");
    }
  }
}
