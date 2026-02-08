import "package:app_logger/app_logger.dart";
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
      _cache[url] = FaviconFinder.getBest(url).then((favicon) {
        return favicon?.url;
      }).catchError((Object error) {
        // Log the error once and cache the null result
        loggerGlobal.warning(
            "FavIcon", "Error while fetching favicon: $error");
        return null;
      });
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
            return SvgPicture.network(
              snapshot.data!,
              width: 16,
              height: 16,
              placeholderBuilder: (context) => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorBuilder: (context, error, stackTrace) {
                // Silently handle SVG parsing errors
                // This catches errors but they still get logged by the SVG parser
                return const Icon(Icons.link, size: 16);
              },
            );
          } else {
            return Image.network(
              snapshot.data!,
              width: 16,
              height: 16,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.link, size: 16);
              },
            );
          }
        }
        if (snapshot.hasError) {
          // Error already logged and cached in _getFavIconUrl
          return const Icon(Icons.link, size: 16);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else {
          return const Icon(Icons.link, size: 16);
        }
      },
    );
  }
}

