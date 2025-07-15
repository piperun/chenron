import "package:chenron/models/item.dart";
import "package:chenron/utils/logger.dart";
import "package:url_launcher/url_launcher.dart";

String convertItemToString(ItemContent content) {
  return switch (content) {
    StringContent(value: final url) => url,
    MapContent(value: final map) => map["title"] ?? "",
  };
}

Function() getLaunchFunc(ItemContent content) {
  return switch (content) {
    StringContent(value: final url) => () => _launchURL(Uri.parse(url)),
    MapContent() => () {},
  };
}

void _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    loggerGlobal.warning("URL", "Could not launch $url");
  }
}
