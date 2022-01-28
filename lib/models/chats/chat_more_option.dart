class MoreOption {
  MoreOption({
    required this.name,
    required this.action,
  });

  final String name;
  final void Function() action;
}
