import 'dart:convert';

abstract class Serializable {
  const Serializable();
  Map<String, dynamic> toMap();
  String toJson() => jsonEncode(toMap());
}
