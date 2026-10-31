class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.pending = false,
  });

  final String id;
  final String senderUid;
  final String senderName;
  final String text;
  final DateTime sentAt;

  /// True while this message only exists in the local Firestore write cache
  /// and hasn't been acknowledged by the server yet (`DocumentSnapshot
  /// .metadata.hasPendingWrites`) — used to show a "sending" indicator on
  /// the sender's own bubble until it flips to sent.
  final bool pending;
}
