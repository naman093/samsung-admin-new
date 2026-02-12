enum ContentType {
  vod,
  podcast,
  feed;

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContentType.feed,
    );
  }

  String toJson() => name;
}

enum TransactionType {
  spent,
  earned,
  refunded;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.earned,
    );
  }

  String toJson() => name;
}
