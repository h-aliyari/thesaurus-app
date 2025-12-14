class DocContent {
  final int id;
  final int docId;
  final String? volumeNo;
  final String? pageNo;
  final String? textContent;
  final String? rawTextContent;

  DocContent({
    required this.id,
    required this.docId,
    this.volumeNo,
    this.pageNo,
    this.textContent,
    this.rawTextContent,
  });

  factory DocContent.fromJson(Map<String, dynamic> json) {
    return DocContent(
      id: int.tryParse(json['DocContentId']?.toString() ?? '') ?? 0,
      docId: int.tryParse(json['DocId']?.toString() ?? '') ?? 0,
      volumeNo: json['VolumeNo']?.toString(),
      pageNo: json['PageNo']?.toString(),
      textContent: json['TextContent']?.toString(),
      rawTextContent: json['RawTextContent']?.toString(),
    );
  }

  @override
  String toString() {
    return 'DocContent(id: $id, docId: $docId, pageNo: $pageNo, textContent: $textContent)';
  }
}
