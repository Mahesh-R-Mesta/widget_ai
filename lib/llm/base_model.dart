import 'package:langchain/langchain.dart';

abstract class BaseLLMModel {
  final BaseChatModel model;

  BaseLLMModel(this.model);

  Future<String> invoke(String prompt) async {
    final response = await model.invoke(PromptValue.string(prompt));
    return response.output.content;
  }

  Stream<String> stream(String prompt) {
    return model.stream(PromptValue.string(prompt)).map((chunk) => chunk.output.content);
  }
}
