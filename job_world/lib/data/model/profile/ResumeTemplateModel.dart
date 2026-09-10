class ResumeTemplateModel {
  final int id;
  final String templateName;
  final String? htmlFile;
  final String? cssFile;
  final String? htmlContent;
  final String? cssContent;
  final String? createdAt;

  ResumeTemplateModel({
    required this.id,
    required this.templateName,
    this.htmlFile,
    this.cssFile,
    this.htmlContent,
    this.cssContent,
    this.createdAt,
  });

  factory ResumeTemplateModel.fromJson(Map<String, dynamic> json) {
    final String? hContent = json['html_content'] ??
        json['htmlContent'] ??
        json['html'] ??
        json['template_html'] ??
        json['content'] ??
        json['html_file'];

    final String? cContent = json['css_content'] ??
        json['cssContent'] ??
        json['css'] ??
        json['template_css'] ??
        json['css_file'];

    return ResumeTemplateModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      templateName: json['template_name'] ?? json['name'] ?? json['title'] ?? 'Template',
      htmlFile: json['html_file']?.toString(),
      cssFile: json['css_file']?.toString(),
      htmlContent: hContent?.toString(),
      cssContent: cContent?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_name': templateName,
      'html_file': htmlFile,
      'css_file': cssFile,
      'html_content': htmlContent,
      'css_content': cssContent,
      'created_at': createdAt,
    };
  }
}
