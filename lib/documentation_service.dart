import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class DocumentationService {
  static const String _documentationUrl =
      'https://xalera321.github.io/flutter_calculator/docs/calculator_documentation.md';

  Future<String> getDocumentation() async {
    try {
      final response = await http.get(Uri.parse(_documentationUrl));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load documentation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading documentation: $e');
    }
  }
}

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  final DocumentationService _documentationService = DocumentationService();
  String _content = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocumentation();
  }

  Future<void> _loadDocumentation() async {
    try {
      final content = await _documentationService.getDocumentation();
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Документация'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocumentation,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ошибка загрузки документации:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDocumentation,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : Markdown(
                  data: _content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    h1: Theme.of(context).textTheme.headlineLarge,
                    h2: Theme.of(context).textTheme.headlineMedium,
                    h3: Theme.of(context).textTheme.headlineSmall,
                    p: Theme.of(context).textTheme.bodyLarge,
                    code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          backgroundColor: Colors.grey[200],
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
    );
  }
}
