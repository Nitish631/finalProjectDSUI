class DocumentModel {
  final String documentId;
  final String filename;
  final String status;
  final String filePath;

  DocumentModel({
    required this.documentId,
    required this.filename,
    required this.status,
    required this.filePath,
  });

  factory DocumentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DocumentModel(
      documentId: json["document_id"] ?? "",
      filename: json["filename"] ?? "",
      status: json["status"] ?? "",
      filePath: json["file_path"] ?? "",
    );
  }
}