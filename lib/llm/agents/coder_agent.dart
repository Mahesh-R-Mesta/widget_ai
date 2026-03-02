import 'package:widget_ai/llm/agents/base_agent.dart';
import 'package:widget_ai/llm/base_model.dart';

class CoderAgent extends BaseAgent {
  final BaseLLMModel model;

  CoderAgent({required this.model})
    : super(
        name: 'Coder',
        role: 'Developer',
        instructions: '''
You are the "Coder Agent." Your role is to implement the application based on the technical plan provided by the Planner.
Rules:
1. Generate complete, production-ready code.
2. Wrap each file in a markdown code block starting with /* filename: <name> */.
3. Follow best practices for HTML, CSS, and Vanilla JS.
4. Ensure the UI is responsive and premium.
''',
      );

  @override
  Future<AgentResponse> process(AgentState state) async {
    final plan = state.data['plan'] ?? 'No plan provided.';

    final prompt =
        '''
$instructions

Technical Plan:
$plan

Context:
${state.data['projectDetails'] ?? 'No project details provided.'}

Please generate the code now.
''';

    final response = await model.invoke(prompt);

    return AgentResponse(content: response, updatedData: {'code': response});
  }
}
