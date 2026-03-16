import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:widget_ai/llm/models/base_model.dart';

class AnthropicModel extends BaseLLMModel {
  AnthropicModel({required final String apiKey, final String modelName = 'claude-sonnet-4-5'})
    : super(
        ChatAnthropic(
          apiKey: apiKey,
          defaultOptions: ChatAnthropicOptions(model: modelName),
        ),
      );
}
