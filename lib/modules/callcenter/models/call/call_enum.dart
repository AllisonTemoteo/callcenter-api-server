enum Direction {
  inBound(0, 'in'),
  outBound(1, 'out'),
  lateral(2, 'transference');

  final int code;
  final String str;
  const Direction(this.code, this.str);

  static Direction fromCode(int code) {
    return Direction.values.firstWhere((dir) => dir.code == code);
  }
}

// enum CallStatus {
//   unknown(-1, 'UNKNOWN'),
//   answered(0, 'ANSWERED'),
//   notAnsweredAgent(1, 'NOT_ANSWERED_AGENT'),
//   notAnsweredPeer(2, 'NOT_ASWERED_PEER'),
//   busy(3, 'BUSY'),
//   doNotDisturb(4, 'DO_NOT_DISTURB');

//   final int code;
//   final String str;
//   const CallStatus(this.code, this.str);

//   static CallStatus fromCode(int code) {
//     return CallStatus.values.firstWhere((status) => status.code == code);
//   }
// }

// enum CallHangupCause {
//   unknown(-1, 'UNKNOWN'),
//   abandon(0, 'ABANDON'),
//   completeAgent(1, 'COMPLETE_AGENT'),
//   completePeer(2, 'COMPLETE_PEER'),
//   transference(3, 'TRANSFERENCE');

//   final int code;
//   final String str;
//   const CallHangupCause(this.code, this.str);

//   static CallHangupCause fromCode(int code) {
//     return CallHangupCause.values.firstWhere((cause) => cause.code == code);
//   }
// }

// enum Event {
//   unknown(-1, 'UNKNOWN'),
//   abandon(0, 'ABANDON'),
//   completeAgent(1, 'COMPLETE_AGENT'),
//   completePeer(2, 'COMPLETE_PEER'),
//   ringNoAnswer(3, 'RING_NO_ANSWER');

//   final int code;
//   final String str;
//   const Event(this.code, this.str);

//   static Event fromCode(int code) {
//     return Event.values.firstWhere((cause) => cause.code == code);
//   }
// }
