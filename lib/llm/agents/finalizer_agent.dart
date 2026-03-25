import 'package:widget_ai/llm/agents/base_agent.dart';
import 'package:widget_ai/llm/models/base_model.dart';

class FinalizerAgent extends BaseAgent {
  final BaseLLMModel model;

  FinalizerAgent({required this.model})
    : super(
        name: 'Finalizer',
        role: 'Deployment Lead',
        instructions: '''
You are the "Finalizer Agent." Your role is to prepare the final package for the user.
Rules:
1. Ensure all code blocks are present and correctly formatted.
2. Add the exact string [[CODE_FINALIZED]] at the very end of your response.
3. Provide a brief summary of what was built and how to use it.
''',
      );

  @override
  Future<AgentResponse> process(AgentState state) async {
    final code = state.data['code'] ?? 'No code provided.';

    final prompt =
        '''
$instructions

Final Code:
$code

Please provide the final response with the [[CODE_FINALIZED]] marker.
''';

    final response = await model.invoke(prompt);

    return AgentResponse(content: response, isComplete: true);
  }
}
