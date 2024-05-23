import 'dart:convert';

class NotificationInfo {
  final String senderName;
  final String avatar;
  final String content;
  final String value;
  final Function(String payload)? onPressed;
  NotificationInfo({
    required this.senderName,
    required this.avatar,
    required this.content,
    required this.value,
    this.onPressed,
  });

  NotificationInfo copyWith({
    String? senderName,
    String? avatar,
    String? content,
    String? value,
    Function(String payload)? onPressed,
  }) {
    return NotificationInfo(
      senderName: senderName ?? this.senderName,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      value: value ?? this.value,
      onPressed: onPressed ?? this.onPressed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderName': senderName,
      'avatar': avatar,
      'content': content,
      'value': value,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'NotificationInfo(senderName: $senderName, avatar: $avatar, content: $content, value: $value, onPressed: $onPressed)';
  }

  @override
  bool operator ==(covariant NotificationInfo other) {
    if (identical(this, other)) return true;

    return other.senderName == senderName &&
        other.avatar == avatar &&
        other.content == content &&
        other.value == value &&
        other.onPressed == onPressed;
  }

  @override
  int get hashCode {
    return senderName.hashCode ^
        avatar.hashCode ^
        content.hashCode ^
        value.hashCode ^
        onPressed.hashCode;
  }
}
