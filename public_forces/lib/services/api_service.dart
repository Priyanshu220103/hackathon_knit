import 'dart:convert';
import 'package:http/http.dart' as http;

/// API service class containing pure functions for API calls
class ApiService {
  // Base URL for the API
  static const String baseUrl = 'https://thats-elderly-cadillac-incident.trycloudflare.com';

  /// Pure function to call the analysis-data API endpoint
  /// 
  /// [tableName] - The name of the table to analyze
  /// [page] - The page number for pagination (optional, defaults to 1)
  /// [pageSize] - The number of items per page (optional, defaults to 20)
  /// Returns a Future<Map<String, dynamic>> containing the API response
  static Future<Map<String, dynamic>> getAnalysisData({
    required String tableName,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/analysis-data');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['table_name'] = tableName;
      request.fields['page'] = page.toString();
      request.fields['page_size'] = pageSize.toString();
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Failed to get analysis data: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error calling analysis-data API: $e');
    }
  }

  /// Pure function to make a generic GET request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [headers] - Optional headers to include in the request
  /// Returns a Future<Map<String, dynamic>> containing the API response
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'GET request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error making GET request: $e');
    }
  }

  /// Pure function to make a generic POST request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [body] - The request body as a Map
  /// [headers] - Optional headers to include in the request
  /// Returns a Future<Map<String, dynamic>> containing the API response
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'POST request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error making POST request: $e');
    }
  }

  /// Pure function to make a generic PUT request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [body] - The request body as a Map
  /// [headers] - Optional headers to include in the request
  /// Returns a Future<Map<String, dynamic>> containing the API response
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'PUT request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error making PUT request: $e');
    }
  }

  /// Pure function to make a generic DELETE request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [headers] - Optional headers to include in the request
  /// Returns a Future<Map<String, dynamic>> containing the API response
  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isEmpty 
            ? <String, dynamic>{} 
            : json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'DELETE request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error making DELETE request: $e');
    }
  }

  /// Pure function to get cost prediction
  /// 
  /// [originalCost] - The original cost of the project
  /// [projectCount] - The number of projects
  /// [cumulativeExpenditure] - The cumulative expenditure
  /// Returns a Future<Map<String, dynamic>> containing the prediction response
  static Future<Map<String, dynamic>> getPrediction({
    required double originalCost,
    required int projectCount,
    required double cumulativeExpenditure,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/prediction-for-cost');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['original_cost'] = originalCost.toString();
      request.fields['project_count'] = projectCount.toString();
      request.fields['cumulative_expenditure'] = cumulativeExpenditure.toString();
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Failed to get prediction: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Error calling prediction API: $e');
    }
  }
}

/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return statusCode != null 
        ? 'ApiException: $message (Status: $statusCode)'
        : 'ApiException: $message';
  }
}
