import 'package:langchain_core/chat_models.dart' as lc;
import 'package:widget_ai/llm/agents/base_agent.dart';
import 'package:widget_ai/llm/models/base_model.dart';
import 'package:widget_ai/llm/agents/planner_agent.dart';
import 'package:widget_ai/llm/agents/coder_agent.dart';
import 'package:widget_ai/llm/agents/reviewer_agent.dart';
import 'package:widget_ai/llm/agents/debugger_agent.dart';
import 'package:widget_ai/llm/agents/finalizer_agent.dart';

class MultiAgentOrchestrator {
  final BaseLLMModel model;
  late final PlannerAgent planner;
  late final CoderAgent coder;
  late final ReviewerAgent reviewer;
  late final DebuggerAgent debugger;
  late final FinalizerAgent finalizer;

  MultiAgentOrchestrator({required this.model}) {
    planner = PlannerAgent(model: model);
    coder = CoderAgent(model: model);
    reviewer = ReviewerAgent(model: model);
    debugger = DebuggerAgent(model: model);
    finalizer = FinalizerAgent(model: model);
  }

  Stream<OrchestratorStep> runWorkflow(String userRequirement, Map<String, dynamic> projectDetails) async* {
    AgentState state = AgentState(
      history: [lc.HumanChatMessage(content: lc.ChatMessageContent.text(userRequirement))],
      data: {'projectDetails': projectDetails},
    );

    // 1. Planning
    yield OrchestratorStep(agentName: planner.name, status: 'Planning...');
    final planResponse = await planner.process(state);
    state = state.copyWith(data: {...state.data, ...?planResponse.updatedData});
    yield OrchestratorStep(agentName: planner.name, content: planResponse.content, status: 'Plan Generated');

    // 2. Coding
    yield OrchestratorStep(agentName: coder.name, status: 'Coding...');
    final codeResponse = await coder.process(state);
    state = state.copyWith(data: {...state.data, ...?codeResponse.updatedData});
    yield OrchestratorStep(agentName: coder.name, content: codeResponse.content, status: 'Code Generated');

    // 3. Review & Debug Loop (Max 2 iterations for safety)
    int iterations = 0;
    bool passed = false;
    while (!passed && iterations < 2) {
      iterations++;
      yield OrchestratorStep(agentName: reviewer.name, status: 'Reviewing (Attempt $iterations)...');
      final reviewResponse = await reviewer.process(state);
      state = state.copyWith(data: {...state.data, ...?reviewResponse.updatedData});
      passed = state.data['reviewPassed'] == true;

      if (!passed) {
        yield OrchestratorStep(agentName: reviewer.name, content: reviewResponse.content, status: 'Review Failed');
        yield OrchestratorStep(agentName: debugger.name, status: 'Debugging...');
        final debugResponse = await debugger.process(state);
        state = state.copyWith(data: {...state.data, ...?debugResponse.updatedData});
        yield OrchestratorStep(agentName: debugger.name, content: debugResponse.content, status: 'Issues Fixed');
      } else {
        yield OrchestratorStep(agentName: reviewer.name, content: reviewResponse.content, status: 'Review Passed');
      }
    }

    // 4. Finalizing
    yield OrchestratorStep(agentName: finalizer.name, status: 'Finalizing...');
    final finalResponse = await finalizer.process(state);
    yield OrchestratorStep(
      agentName: finalizer.name,
      content: finalResponse.content,
      status: 'Workflow Complete',
      isFinal: true,
    );
  }
}

class OrchestratorStep {
  final String agentName;
  final String? content;
  final String status;
  final bool isFinal;

  OrchestratorStep({required this.agentName, this.content, required this.status, this.isFinal = false});
}
