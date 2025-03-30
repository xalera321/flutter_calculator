import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
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

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  final DocumentationService _service = DocumentationService();
  String _content = '';
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  Future<void> _loadDocumentation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await _service.getDocumentation();
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
          _isInitialized = true;
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Документация'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocumentation,
          ),
        ],
      ),
      body: !_isInitialized
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Нажмите кнопку обновления для загрузки документации',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDocumentation,
                    child: const Text('Загрузить документацию'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ошибка загрузки документации: $_error',
                            style: const TextStyle(color: Colors.red),
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
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Markdown(
                          data: _content,
                          selectable: true,
                        ),
                      ),
                    ),
    );
  }
}
