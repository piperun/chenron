String removeDupSpaces(String input) {
  return input.replaceAll(RegExp(r"\s{2,}"), " ").trim();
}

String removeTrailingSlash(String input) {
  return input.endsWith("/") ? input.substring(0, input.length - 1) : input;
}

