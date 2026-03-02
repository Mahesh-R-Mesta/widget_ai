import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for performing web searches.
///
/// Currently uses a simple implementation or a placeholder if no API key is available.
/// In a production app, this would integrate with Google Search JSON API, Tavily, or similar.
class WebSearchService {
  final String? _apiKey;
  final String? _cx; // Custom Search Engine ID

  WebSearchService({String? apiKey, String? cx}) : _apiKey = apiKey, _cx = cx;

  /// Performs a search and returns a formatted string of results.
  Future<String> search(String query) async {
    if (_apiKey == null || _cx == null) {
      // Return a simulated result for now if keys are missing
      return 'Simulation: No Google Search API key provided. Searching for: $query... \n'
          'Results would typically include links and snippets from documentation, '
          'GitHub, and technical blogs.';
    }

    try {
      final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$_apiKey&cx=$_cx&q=${Uri.encodeComponent(query)}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          return 'No results found for "$query".';
        }

        final buffer = StringBuffer();
        buffer.writeln('Search results for "$query":');
        for (var i = 0; i < items.length && i < 5; i++) {
          final item = items[i];
          buffer.writeln('${i + 1}. ${item['title']}');
          buffer.writeln('   URL: ${item['link']}');
          buffer.writeln('   Snippet: ${item['snippet']}');
          buffer.writeln('');
        }
        return buffer.toString();
      } else {
        return 'Search failed with status: ${response.statusCode}. body: ${response.body}';
      }
    } catch (e) {
      return 'Error during search: $e';
    }
  }
}
