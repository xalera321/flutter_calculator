import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentationService {
  static const String _url =
      'https://xalera321.github.io/flutter_calculator/calculator_documentation.md';
  static const String _cacheKey = 'documentation_cache';
  static const Duration _cacheDuration = Duration(hours: 24);

  Future<String> getDocumentation() async {
    try {
      // Try to get cached content first
      final prefs = await SharedPreferences.getInstance();
      final cachedContent = prefs.getString(_cacheKey);
      final lastUpdate = prefs.getInt('${_cacheKey}_timestamp');

      if (cachedContent != null && lastUpdate != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
        if (cacheAge < _cacheDuration.inMilliseconds) {
          return cachedContent;
        }
      }

      // If no cache or cache is old, try to fetch from network
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final content = response.body;

        // Cache the new content
        await prefs.setString(_cacheKey, content);
        await prefs.setInt(
            '${_cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);

        return content;
      } else {
        throw Exception('Failed to load documentation: ${response.statusCode}');
      }
    } catch (e) {
      // If network request fails, try to return cached content
      final prefs = await SharedPreferences.getInstance();
      final cachedContent = prefs.getString(_cacheKey);

      if (cachedContent != null) {
        return cachedContent;
      }

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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await _documentationService.getDocumentation();
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
