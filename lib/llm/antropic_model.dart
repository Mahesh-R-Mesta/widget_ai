import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:widget_ai/llm/base_model.dart';

class AnthropicModel extends BaseLLMModel {
  AnthropicModel({required final String apiKey, final String modelName = 'claude-opus-4-6'})
    : super(
        ChatAnthropic(
          apiKey: apiKey,
          defaultOptions: ChatAnthropicOptions(model: modelName),
        ),
      );
}
