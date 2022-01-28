class ChatExtraFeature {
  ChatExtraFeature({
    this.id = 0,
    this.name,
    this.imagePath,
    this.action,
  });

  final int id;
  String? name;
  String? imagePath;
  void Function()? action;

  bool isEmpty() {
    return id == 0 || name == null || imagePath == null ||action == null;
  }
}
