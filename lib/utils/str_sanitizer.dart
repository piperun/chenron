String removeDupSpaces(String input) {
  return input.replaceAll(RegExp(r"\s{2,}"), " ").trim();
}
