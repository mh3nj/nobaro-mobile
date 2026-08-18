class Template {
  String id;
  String name;
  String description;
  String content;
  String tags;
  int useCount;

  Template({
    this.id = '',
    this.name = '',
    this.description = '',
    this.content = '',
    this.tags = '',
    this.useCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'content': content,
        'tags': tags,
        'use_count': useCount,
      };

  factory Template.fromJson(Map<String, dynamic> json) => Template(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        content: json['content'] as String? ?? '',
        tags: json['tags'] as String? ?? '',
        useCount: json['use_count'] as int? ?? 0,
      );
}
