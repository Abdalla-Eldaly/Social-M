class Hashtag {
  final int id;
  final String name;
  final int postCount;

  Hashtag({
    required this.id,
    required this.name,
    required this.postCount,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) {
    return Hashtag(
      id: json['id'] as int,
      name: json['name'] as String,
      postCount: json['postCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'postCount': postCount,
    };
  }
}