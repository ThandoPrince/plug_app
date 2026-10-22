class ProviderQualificationModel {
  final int id;
  final int providerService;
  final String documentType;
  final String? title;
  final String? issuingBody;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? documentUrl;
  final DateTime? uploadedAt;

  ProviderQualificationModel({
    required this.id,
    required this.providerService,
    required this.documentType,
    this.title,
    this.issuingBody,
    this.issueDate,
    this.expiryDate,
    this.documentUrl,
    this.uploadedAt,
  });

  factory ProviderQualificationModel.fromJson(Map<String, dynamic> json) {
    return ProviderQualificationModel(
      id: json['id'] as int,
      providerService: json['provider_service'] as int,
      documentType: json['document_type']?.toString() ?? '',
      title: json['title']?.toString(),
      issuingBody: json['issuing_body']?.toString(),
      issueDate: json['issue_date'] != null
          ? DateTime.tryParse(json['issue_date'].toString())
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      documentUrl: json['document_url']?.toString(),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString())
          : null,
    );
  }

  // ---------------------------------------------------------------
  // Extension helpers — mirrors the backend's allowed_extensions set:
  // {.pdf, .jpg, .jpeg, .png, .doc, .docx}
  // ---------------------------------------------------------------

  String? get _extension {
    final url = documentUrl;
    if (url == null || url.isEmpty) return null;

    final withoutQuery = url.split('?').first;
    final dotIndex = withoutQuery.lastIndexOf('.');
    if (dotIndex == -1) return null;

    return withoutQuery.substring(dotIndex).toLowerCase();
  }

  bool get isImage => const {'.jpg', '.jpeg', '.png'}.contains(_extension);
  bool get isPdf => _extension == '.pdf';
  bool get isDoc => const {'.doc', '.docx'}.contains(_extension);

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
}