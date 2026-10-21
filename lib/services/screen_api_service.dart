import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mdns_resolver.dart';

class ScreenTaskItem {
  final int id;
  final String text;
  final bool done;
  final String createdAt;

  const ScreenTaskItem({
    required this.id,
    required this.text,
    required this.done,
    required this.createdAt,
  });

  factory ScreenTaskItem.fromJson(Map<String, dynamic> json) {
    return ScreenTaskItem(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ScreenApiService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;
  final MdnsResolver _mdnsResolver;

  ScreenApiService({
    this.baseUrl = 'http://screen.local',
    http.Client? client,
    this.timeout = const Duration(seconds: 7),
    MdnsResolver? mdnsResolver,
  })  : _client = client ?? http.Client(),
        _mdnsResolver = mdnsResolver ?? MdnsResolver();

  Future<Uri> _resolveUri(String path) async {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final parsed = Uri.parse('$cleanBase$cleanPath');

    if (parsed.host.endsWith('.local')) {
      final ip = await _mdnsResolver.resolveHost(parsed.host);
      return parsed.replace(host: ip);
    }
    return parsed;
  }

  void _invalidateHost() {
    try {
      final host = Uri.parse(baseUrl).host;
      if (host.endsWith('.local')) {
        _mdnsResolver.invalidate(host);
      }
    } catch (_) {}
  }

  Future<List<ScreenTaskItem>> fetchTasks() async {
    final uri = await _resolveUri('/tasks');
    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => ScreenTaskItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch tasks from screen: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _invalidateHost();
      rethrow;
    }
  }

  Future<bool> deleteTask(int id) async {
    final uri = await _resolveUri('/tasks/$id');
    try {
      final response = await _client.delete(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete task $id from screen: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _invalidateHost();
      rethrow;
    }
  }

  Future<List<ScreenTaskItem>> createTasks(List<String> texts) async {
    if (texts.isEmpty) return [];

    final payload = jsonEncode(texts.map((t) => {'text': t}).toList());
    final uri = await _resolveUri('/tasks');
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => ScreenTaskItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to create tasks on screen: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _invalidateHost();
      rethrow;
    }
  }
}
