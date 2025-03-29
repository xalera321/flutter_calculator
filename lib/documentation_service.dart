import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class DocumentationService {
  static const String _documentationUrl = 'YOUR_CDN_URL/calculator_guide.md';

  static Future<String> fetchDocumentation() async {
    try {
      final response = await http.get(Uri.parse(_documentationUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load documentation');
      }
    } catch (e) {
      return '''
# Error Loading Documentation

Unable to load the documentation from the server. Please check your internet connection and try again later.

## Offline Documentation

### Basic Operations
- Addition (+)
- Subtraction (-)
- Multiplication (×)
- Division (÷)

### Advanced Operations
- Percentage (%)
- Square Root (√)
- Power (^)

For more detailed information, please check the documentation when you're online.
''';
    }
  }
}

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator Guide'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<String>(
        future: DocumentationService.fetchDocumentation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Markdown(
            data: snapshot.data ?? 'No documentation available',
            selectable: true,
            padding: const EdgeInsets.all(16.0),
          );
        },
      ),
    );
  }
}
