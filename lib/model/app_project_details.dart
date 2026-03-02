class AppProjectDetails {
  final String appName;
  final String description;
  final String? iconImagePath;
  final String llmModel;

  const AppProjectDetails({
    required this.appName,
    required this.description,
    this.iconImagePath,
    this.llmModel = 'gemini',
  });

  /// Converts the project details into a concise string that is prepended
  /// to the system prompt so the LLM understands the project context.
  String toContextString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Project Details Provided by User ===');
    buffer.writeln('App Name: $appName');
    buffer.writeln('Description: $description');
    buffer.writeln('LLM Model: $llmModel');
    if (iconImagePath != null) {
      buffer.writeln('Icon: $iconImagePath');
    }
    buffer.writeln('========================================');
    return buffer.toString();
  }
}
