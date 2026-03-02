import 'package:widget_ai/llm/agents/base_agent.dart';
import 'package:widget_ai/llm/base_model.dart';

class PlannerAgent extends BaseAgent {
  final BaseLLMModel model;

  PlannerAgent({required this.model})
    : super(
        name: 'Planner',
        role: 'Architect',
        instructions: '''
You are the "Planner Agent." Your role is to analyze user requirements and create a high-level technical blueprint.
Your plan should include:
1. Proposed app structure (files and folders).
2. Key features and their implementation strategy.
3. Choice of libraries or CDNs to be used.
4. Any potential challenges or edge cases.
Keep your plan concise and focused on technical execution.
''',
      );

  @override
  Future<AgentResponse> process(AgentState state) async {
    // Inject agent instructions as a system message if not already present or as a prefix
    final prompt =
        '''
$instructions

Context:
${state.data['projectDetails'] ?? 'No project details provided.'}

Please provide the technical plan.
''';

    final response = await model.invoke(prompt);

    return AgentResponse(content: response, updatedData: {'plan': response});
  }
}
