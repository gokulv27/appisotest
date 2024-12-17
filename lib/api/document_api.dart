import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/document.dart';
import '../confing/ipadders.dart'; // ApiConfig class for baseUrl
import '../confing/header.dart'; // ApiHeaders class for headers

class DocumentService {
  /// Fetch project documents by project ID
  Future<List<Document>> getProjectDocuments(int projectId, {String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}api/project/document/$projectId/list/');
    try {
      final response = await http.get(url, headers: ApiHeaders.getHeaders(token: token));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception(
          'Failed to load documents: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching documents: $e');
    }
  }

  /// Upload a document
  Future<bool> uploadDocument({
    required File file,
    required String documentName,
    required int projectId,
    required int documentTypeId,
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}api/project/document/create/');
    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(ApiHeaders.getHeaders(token: token))
        ..fields['document_name'] = documentName
        ..fields['project_id'] = projectId.toString()
        ..fields['document_type'] = documentTypeId.toString()
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to upload document: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  /// Download a document
  Future<File> downloadDocument({
    required String url,
    required String savePath,
    String? token,
  }) async {
    try {
      final response = await http.get(Uri.parse(url), headers: ApiHeaders.getHeaders(token: token));

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception(
          'Failed to download document: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error downloading document: $e');
    }
  }

  /// Delete a document by ID
  Future<void> deleteDocument(int documentId, {String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}api/project/document/delete/$documentId/');
    try {
      final response = await http.delete(url, headers: ApiHeaders.getHeaders(token: token));

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete document: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  /// Fetch document types (to assist in uploading with valid `document_type_id`)
  Future<List<Map<String, dynamic>>> fetchDocumentTypes({String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}api/master/document-type/');
    try {
      final response = await http.get(url, headers: ApiHeaders.getHeaders(token: token));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true && responseBody['data'] is List) {
          return List<Map<String, dynamic>>.from(responseBody['data']);
        } else {
          throw Exception('Unexpected API response structure');
        }
      } else {
        throw Exception(
          'Failed to fetch document types: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching document types: $e');
    }
  }
}
