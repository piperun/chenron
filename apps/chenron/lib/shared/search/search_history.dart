import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class SearchHistoryItem {
  final String type;
  final String id;
  final String title;
  final DateTime timestamp;

  const SearchHistoryItem({
    required this.type,
    required this.id,
    required this.title,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "title": title,
        "timestamp": timestamp.toIso8601String(),
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      type: json["type"] as String,
      id: json["id"] as String,
      title: json["title"] as String,
      timestamp: DateTime.parse(json["timestamp"] as String),
    );
  }
}

class SearchHistoryManager {
  static const String _key = "recent_searches";
  static const int _maxHistorySize = 10;

  Future<List<SearchHistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_key);

    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded
        .map((item) => SearchHistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistoryItem({
    required String type,
    required String id,
    required String title,
  }) async {
    final history = await loadHistory();

    // Remove existing entry if it exists (to update timestamp)
    history.removeWhere((item) => item.id == id && item.type == type);

    // Add new entry at the beginning
    history.insert(
      0,
      SearchHistoryItem(
        type: type,
        id: id,
        title: title,
        timestamp: DateTime.now(),
      ),
    );

    // Keep only the last N entries
    if (history.length > _maxHistorySize) {
      history.removeRange(_maxHistorySize, history.length);
    }

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
