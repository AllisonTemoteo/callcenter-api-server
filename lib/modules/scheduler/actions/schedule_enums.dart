enum ActionType {
  echo(0, 'echo'),
  syncCalls(1, 'sync_calls');

  final int code;
  final String name;
  const ActionType(this.code, this.name);

  static ActionType fromCode(int code) {
    return values.firstWhere((type) => type.code == code);
  }
}

enum Status {
  failed(-1, 'FAILED'),
  idle(0, 'IDLE'),
  running(1, 'RUNNING'),
  completed(2, 'COMPLETED');

  final int code;
  final String str;
  const Status(this.code, this.str);

  static Status fromCode(int code) {
    return values.firstWhere((type) => type.code == code);
  }
}
