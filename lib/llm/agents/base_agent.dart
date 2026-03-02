import 'package:langchain_core/chat_models.dart' as lc;

/// Base interface for all agents in the multi-agent system.
abstract class BaseAgent {
  final String name;
  final String role;
  final String instructions;

  BaseAgent({required this.name, required this.role, required this.instructions});

  /// Processes the given state and returns a response.
  Future<AgentResponse> process(AgentState state);
}

/// Represents the state passed between agents.
class AgentState {
  final List<lc.ChatMessage> history;
  final Map<String, dynamic> data;

  AgentState({required this.history, this.data = const {}});

  AgentState copyWith({List<lc.ChatMessage>? history, Map<String, dynamic>? data}) {
    return AgentState(history: history ?? this.history, data: data ?? this.data);
  }
}

/// Represents the response from an agent.
class AgentResponse {
  final String content;
  final Map<String, dynamic>? updatedData;
  final bool isComplete;

  AgentResponse({required this.content, this.updatedData, this.isComplete = false});
}
