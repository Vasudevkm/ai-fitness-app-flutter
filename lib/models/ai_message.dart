enum MessageRole { user, assistant }

class AIMessage {
  final String text;
  final MessageRole role;

  AIMessage({
    required this.text,
    required this.role,
  });
}
