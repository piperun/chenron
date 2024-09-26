import 'package:chenron/models/item.dart';
import 'package:url_launcher/url_launcher.dart';

String convertItemToString(ItemContent content) {
  switch (content) {
    case StringContent stringContent:
      return stringContent.value;
    case MapContent mapContent:
      return mapContent.value['title'] ?? '';
    default:
      return '';
  }
}

Function() getLaunchFunc(ItemContent content) {
  switch (content) {
    case StringContent stringContent:
      return () => _launchURL(Uri.parse(stringContent.value));
    default:
      return () {};
  }
}

void _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print('Could not launch $url');
  }
}
