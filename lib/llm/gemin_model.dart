import 'package:langchain_google/langchain_google.dart';
import 'package:widget_ai/llm/base_model.dart';

class GeminiModel extends BaseLLMModel {
  GeminiModel({required final String apiKey, final String modelName = 'gemini-flash-latest'})
    : super(
        ChatGoogleGenerativeAI(
          apiKey: apiKey,
          defaultOptions: ChatGoogleGenerativeAIOptions(model: modelName, enableCodeExecution: false),
        ),
      );
}
