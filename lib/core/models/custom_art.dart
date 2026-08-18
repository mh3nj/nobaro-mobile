class CustomArt {
  String id;
  String name;
  String content;
  String createdAt;

  CustomArt({
    this.id = '',
    this.name = '',
    this.content = '',
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'content': content,
        'created_at': createdAt,
      };

  factory CustomArt.fromJson(Map<String, dynamic> json) => CustomArt(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}
