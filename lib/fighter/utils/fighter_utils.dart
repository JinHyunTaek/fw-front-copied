class FighterUtils {
  static String Name(String name) {
    return name.contains(' ') ? name.split(' ')[0] : name;
  }

  static List<String> splitFirstAndLastName(String name) {
    final idx = name.indexOf(' ');
    return idx == -1
        ? [name, '']
        : [name.substring(0, idx), name.substring(idx + 1)];
  }
}
