class MediaRef {
  String path;
  String mediaType;
  String caption;

  MediaRef({
    this.path = '',
    this.mediaType = 'file',
    this.caption = '',
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'media_type': mediaType,
        'caption': caption,
      };

  factory MediaRef.fromJson(Map<String, dynamic> json) => MediaRef(
        path: json['path'] as String? ?? '',
        mediaType: json['media_type'] as String? ?? 'file',
        caption: json['caption'] as String? ?? '',
      );
}

class Note {
  String id;
  String date;
  String timeWritten;
  String mood;
  String content;
  String tags;
  String noteType;
  String sealedUntil;
  int xpEarned;
  int wordCount;
  List<Map<String, dynamic>> formatting;
  List<MediaRef> media;

  Note({
    this.id = '',
    this.date = '',
    this.timeWritten = '',
    this.mood = ':|',
    this.content = '',
    this.tags = '',
    this.noteType = 'normal',
    this.sealedUntil = '',
    this.xpEarned = 0,
    this.wordCount = 0,
    List<Map<String, dynamic>>? formatting,
    List<MediaRef>? media,
  })  : formatting = formatting ?? [],
        media = media ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time_written': timeWritten,
        'mood': mood,
        'content': content,
        'tags': tags,
        'note_type': noteType,
        'sealed_until': sealedUntil,
        'xp_earned': xpEarned,
        'word_count': wordCount,
        'formatting': formatting,
        'media': media.map((m) => m.toJson()).toList(),
      };

  static Note clone(Note other) => Note(
        id: other.id,
        date: other.date,
        timeWritten: other.timeWritten,
        mood: other.mood,
        content: other.content,
        tags: other.tags,
        noteType: other.noteType,
        sealedUntil: other.sealedUntil,
        xpEarned: other.xpEarned,
        wordCount: other.wordCount,
        formatting: List.from(other.formatting),
        media: List.from(other.media),
      );

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String? ?? '',
        date: json['date'] as String? ?? '',
        timeWritten: json['time_written'] as String? ?? '',
        mood: json['mood'] as String? ?? ':|',
        content: json['content'] as String? ?? '',
        tags: json['tags'] as String? ?? '',
        noteType: json['note_type'] as String? ?? 'normal',
        sealedUntil: json['sealed_until'] as String? ?? '',
        xpEarned: json['xp_earned'] as int? ?? 0,
        wordCount: json['word_count'] as int? ?? 0,
        formatting: (json['formatting'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
        media: (json['media'] as List<dynamic>?)
                ?.map((e) => MediaRef.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
