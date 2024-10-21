import "package:chenron/utils/logger.dart";
import "package:favicon/favicon.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class Favicon extends StatelessWidget {
  final String url;
  static final Map<String, Future<String?>> _cache = {};

  factory Favicon({Key? key, required String url}) {
    return Favicon._internal(key: key, url: url);
  }

  const Favicon._internal({super.key, required this.url});

  static Future<String?> _getFavIconUrl(String url) async {
    if (!_cache.containsKey(url)) {
      _cache[url] = FaviconFinder.getBest(url).then((favicon) => favicon?.url);
    }
    return _cache[url];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getFavIconUrl(url),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data!.endsWith("svg")) {
            return SvgPicture.network(snapshot.data!);
          } else {
            return Image.network(snapshot.data!);
          }
        }
        if (snapshot.hasError) {
          loggerGlobal.warning(
              "FavIcon", "Error while fetching favicon: ${snapshot.error}");
          return const Icon(Icons.link);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const RepaintBoundary(
            child: CircularProgressIndicator(
                strokeWidth: 8,
                strokeAlign: BorderSide.strokeAlignCenter,
                backgroundColor: Colors.blue),
          );
        } else {
          return const Icon(Icons.link);
        }
      },
    );
  }
}
