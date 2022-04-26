class AUserItem {
  final int id;
  final String name;

  const AUserItem(
      this.id,
      this.name,
  );

  void Rprint() {
    print('id: ' + id.toString() + " name: " + name.toString());
  }
}