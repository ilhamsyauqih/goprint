// lib/data/models/template_model.dart

class TemplateModel {
  final String id;
  final String title;
  final String category; // e.g., 'surat_izin', 'cover_laporan'
  final String? thumbnailUrl;
  final String fileUrl;
  final int downloadCount;
  final DateTime createdAt;

  TemplateModel({
    required this.id,
    required this.title,
    required this.category,
    this.thumbnailUrl,
    required this.fileUrl,
    required this.downloadCount,
    required this.createdAt,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileUrl: json['file_url'] as String,
      downloadCount: json['download_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'download_count': downloadCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TemplateModel copyWith({
    String? id,
    String? title,
    String? category,
    String? thumbnailUrl,
    String? fileUrl,
    int? downloadCount,
    DateTime? createdAt,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      downloadCount: downloadCount ?? this.downloadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
