class Tag {
  final String tagId;
  final String objectType;
  final String objectId;
  final String tagDefinitionId;
  final String tagDefinitionName;
  final List<Map<String, dynamic>> auditLogs;

  const Tag({
    required this.tagId,
    required this.objectType,
    required this.objectId,
    required this.tagDefinitionId,
    required this.tagDefinitionName,
    required this.auditLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.tagId == tagId;
  }

  @override
  int get hashCode => tagId.hashCode;

  @override
  String toString() {
    return 'Tag(tagId: $tagId, tagDefinitionName: $tagDefinitionName, objectType: $objectType)';
  }
}
