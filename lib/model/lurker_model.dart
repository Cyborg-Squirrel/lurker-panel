class LurkerModel {
  LurkerModel({
    required this.profileImageUrl,
    required this.name,
    required this.lurkingStartedAt,
    required int chatsSinceLurk,
  }) : _chatsSinceLurk = chatsSinceLurk;

  /// Url to the chatter's profile image, null if not available
  final String? profileImageUrl;

  /// The name of the chatter
  final String name;

  /// Timestamp when the chatter started lurking
  final DateTime lurkingStartedAt;

  /// Could be used to determine if they are no longer lurking
  int _chatsSinceLurk;

  int get chatsSinceLurk => _chatsSinceLurk;

  void incrementChatsSinceLurk() {
    _chatsSinceLurk++;
  }
}
