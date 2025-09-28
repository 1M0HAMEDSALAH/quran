class AzkarItem {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? filename;

  AzkarItem({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.filename,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    return AzkarItem(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      count: json['count'] ?? 1,
      audio: json['audio'],
      filename: json['filename'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'count': count,
      'audio': audio,
      'filename': filename,
    };
  }
}

class AzkarCategory {
  final int id;
  final String category;
  final String? audio;
  final String? filename;
  final List<AzkarItem> array;

  AzkarCategory({
    required this.id,
    required this.category,
    this.audio,
    this.filename,
    required this.array,
  });

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    var list = json['array'] as List<dynamic>? ?? [];
    List<AzkarItem> azkarItems = list.map((item) => AzkarItem.fromJson(item)).toList();

    return AzkarCategory(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      audio: json['audio'],
      filename: json['filename'],
      array: azkarItems,
    );
  }
}
