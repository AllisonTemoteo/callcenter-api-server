class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end})
    : assert(
        !end.isBefore(start),
        'Data final não pode ser anterior à data inicial',
      );

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  bool overlaps(DateRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  @override
  bool operator ==(Object other) {
    return other is DateRange && start == other.start && end == other.end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
