import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class DocumentationService {
  static const String _documentationUrl =
      'https://xalera321.github.io/flutter_calculator/calculator_documentation.md';

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

class CustomElementBuilder extends MarkdownElementBuilder {
  final BoxDecoration style;
  final EdgeInsets padding;

  CustomElementBuilder({
    required this.style,
    required this.padding,
  });

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      decoration: style,
      padding: padding,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        element.textContent,
        style: preferredStyle,
      ),
    );
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
                    h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                    h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                    p: Theme.of(context).textTheme.bodyLarge,
                    listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    listIndent: 24.0,
                    code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                          fontFamily: 'monospace',
                        ),
                    blockquote: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                    blockquoteDecoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  builders: {
                    'h1': CustomElementBuilder(
                      style: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    'h2': CustomElementBuilder(
                      style: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    'h3': CustomElementBuilder(
                      style: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  },
                ),
    );
  }
}
