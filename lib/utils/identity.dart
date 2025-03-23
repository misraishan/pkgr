class Identity {
  final String name;
  final String id;

  Identity({required this.name, required this.id});

  @override
  String toString() {
    return 'Identity(name: $name, id: $id)';
  }

  String get parts {
    return '$id\t$name';
  }
}
