abstract class ValidableObject<T> {
  const ValidableObject(this.raw);
  final T raw;
  List<String>? validate();
}
