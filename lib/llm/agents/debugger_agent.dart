import 'package:widget_ai/llm/agents/base_agent.dart';
import 'package:widget_ai/llm/models/base_model.dart';

class DebuggerAgent extends BaseAgent {
  final BaseLLMModel model;

  DebuggerAgent({required this.model})
    : super(
        name: 'Debugger',
        role: 'Senior Developer',
        instructions: '''
You are the "Debugger Agent." Your role is to fix issues identified by the Reviewer Agent.
Rules:
1. Re-generate the necessary files with fixes.
2. Wrap each file in a markdown code block starting with /* filename: <name> */.
3. Address all points mentioned in the review feedback.
''',
      );

  @override
  Future<AgentResponse> process(AgentState state) async {
    final code = state.data['code'] ?? 'No code provided.';
    final feedback = state.data['reviewFeedback'] ?? 'No feedback provided.';

    final prompt =
        '''
$instructions

Current Code:
$code

Review Feedback:
$feedback

Please fix the issues and provide the updated code.
''';

    final response = await model.invoke(prompt);

    return AgentResponse(content: response, updatedData: {'code': response});
  }
}
