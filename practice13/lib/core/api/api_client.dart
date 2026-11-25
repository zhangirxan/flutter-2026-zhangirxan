import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  // tests pass a MockClient, the app gets a real one
  ApiClient(
    this._store, {
    http.Client? client,
    this.host = 'jsonplaceholder.typicode.com',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final SecureStore _store;
  final String host;

  // the token is added here, so the repository and the screens never see it
  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };

  Future<dynamic> get(Uri uri) async {
    final headers = await _headers();
    final r = await _send(() => _client.get(uri, headers: headers));
    _check(r);
    return _decode(r);
  }

  Future<dynamic> post(Uri uri, Object body) async {
    final headers = {...await _headers(), 'Content-Type': 'application/json'};
    final r = await _send(
      () => _client.post(uri, headers: headers, body: jsonEncode(body)),
    );
    _check(r);
    if (r.statusCode != 201) {
      throw BadResponseException(
        'POST ${uri.path}: expected 201, got ${r.statusCode}',
      );
    }
    return _decode(r);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  // status first, body after. a 404 body is {} and would pass the decode
  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s >= 400) throw BadResponseException('${r.request?.url}: status $s');
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('${r.request?.url}: ${e.message}');
    }
  }
}
