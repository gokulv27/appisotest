import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/document.dart';
import '../confing/ipadders.dart';

class DocumentService {
  /// Fetch project documents by project ID
  Future<List<Document>> getProjectDocuments(int projectId) async {
    final url = Uri.parse('$baseUrl/api/project/document/$projectId/list/');
    print('Fetching documents from: $url');
    try {
      final response = await http.get(url, headers: _buildHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception(
            'Failed to load documents: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching documents: $e');
      throw Exception('Error fetching documents: $e');
    }
  }

  // Upload document
  Future<bool> uploadDocument({
    required File file,
    required String documentName,
    required int projectId,
    required int documentTypeId,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/project/document/create/'))
      ..fields['document_name'] = documentName
      ..fields['project_id'] = projectId.toString()
      ..fields['document_type'] = documentTypeId.toString()
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await request.send());
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Download a document
  Future<File> downloadDocument({
    required String url,
    required String savePath,
  }) async {
    print('Downloading document from: $url');
    try {
      final response = await http.get(Uri.parse(url), headers: _buildHeaders());

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        print('Document downloaded and saved to: $savePath');
        return file;
      } else {
        throw Exception(
            'Failed to download document: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error downloading document: $e');
      throw Exception('Error downloading document: $e');
    }
  }

  /// Delete a document by ID
  Future<void> deleteDocument(int documentId) async {
    final url = Uri.parse('$baseUrl/api/project/document/delete/$documentId/');
    print('Deleting document with ID: $documentId from: $url');
    try {
      final response = await http.delete(url, headers: _buildHeaders());

      if (response.statusCode == 204) {
        print('Document deleted successfully');
      } else {
        throw Exception(
            'Failed to delete document: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error deleting document: $e');
      throw Exception('Error deleting document: $e');
    }
  }

  /// Fetch document types (to assist in uploading with valid `document_type_id`)
  Future<List<Map<String, dynamic>>> fetchDocumentTypes() async {
    final url = Uri.parse('$baseUrl/api/document/types/');
    print('Fetching document types from: $url');
    try {
      final response = await http.get(url, headers: _buildHeaders());

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to fetch document types: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching document types: $e');
      throw Exception('Error fetching document types: $e');
    }
  }

  /// Helper to build request headers (e.g., for authentication or custom headers)
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Uncomment if an authentication token is needed
      // 'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
    };
  }
}
