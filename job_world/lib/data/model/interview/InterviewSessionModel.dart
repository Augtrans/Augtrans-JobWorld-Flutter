class InterviewSessionModel {
  final int sessionId;
  final String roomName;
  final String livekitUrl;
  final String token;

  InterviewSessionModel({
    required this.sessionId,
    required this.roomName,
    required this.livekitUrl,
    required this.token,
  });

  factory InterviewSessionModel.fromJson(Map<String, dynamic> json) {
    return InterviewSessionModel(
      sessionId: json['session_id'] ?? 0,
      roomName: json['room_name'] ?? '',
      livekitUrl: json['livekit_url'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'room_name': roomName,
      'livekit_url': livekitUrl,
      'token': token,
    };
  }
}
