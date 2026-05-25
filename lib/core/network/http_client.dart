import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class HttpClient {
  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 15);

  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = _decodeBody(response);

    if (statusCode >= 200 && statusCode < 300) {
      return Future.value(body);
    } else if (statusCode == 400) {
      throw BadRequestException(
        message: body['message'] ?? 'Bad request',
        statusCode: statusCode,
      );
    } else if (statusCode == 401) {
      throw UnauthorizedException(
        message: body['message'] ?? 'Unauthorized',
        statusCode: statusCode,
      );
    } else if (statusCode == 404) {
      throw NotFoundException(
        message: body['message'] ?? 'Resource not found',
        statusCode: statusCode,
      );
    } else if (statusCode >= 500) {
      throw ServerException(
        message: body['message'] ?? 'Internal server error',
        statusCode: statusCode,
      );
    } else {
      throw ApiException(
        message: 'Unexpected error occurred',
        statusCode: statusCode,
      );
    }
  }

  dynamic _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<dynamic> _safeRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      return await _handleResponse(response);
    } on SocketException {
      throw NetworkException(
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      throw NetworkException(message: 'HTTP error occurred.');
    } on FormatException {
      throw ApiException(message: 'Invalid response format from server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return _safeRequest(() => http.get(uri, headers: _headers));
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return _safeRequest(
      () => http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return _safeRequest(
      () => http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return _safeRequest(
      () => http.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return _safeRequest(() => http.delete(uri, headers: _headers));
  }
}
