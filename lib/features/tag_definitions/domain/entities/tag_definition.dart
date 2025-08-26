class TagDefinition {
  final String id;
  final bool isControlTag;
  final String name;
  final String description;
  final List<String> applicableObjectTypes;
  final List<Map<String, dynamic>> auditLogs;

  const TagDefinition({
    required this.id,
    required this.isControlTag,
    required this.name,
    required this.description,
    required this.applicableObjectTypes,
    required this.auditLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagDefinition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TagDefinition(id: $id, name: $name, isControlTag: $isControlTag)';
  }
}
