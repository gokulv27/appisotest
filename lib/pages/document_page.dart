import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../api/document_api.dart';
import '../models/document.dart';
import '../widget/project_custom_bottom_navbar.dart';
import 'labor_to_project_page.dart';
import 'pdf_viewer_page.dart';
import 'image_viewer_page.dart';
import 'text_viewer_page.dart';

class DocumentPage extends StatefulWidget {
  final int projectId;

  const DocumentPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final DocumentService _documentService = DocumentService();
  List<Document> _documents = [];
  bool _isLoading = true;
  int _currentIndex = 1; // Default index for Documents tab

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final documents = await _documentService.getProjectDocuments(widget.projectId);
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load documents: $e')),
      );
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      if (index == 0) {
        // Navigate to Project Details Page
        Navigator.pop(context);

      } else if (index == 1) {
        // Navigate to the Documents page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentPage(projectId: widget.projectId),
          ),
        );
      } else if (index == 2) {
        // Navigate to the Labor to Project page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LaborToProjectPage(projectId: widget.projectId),
          ),
        );
      }
      // Add additional navigation logic here if needed
    }
  }


  Future<void> _downloadPDF(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  Future<void> _viewFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      final extension = url.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png'].contains(extension)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerPage(filePath: file.path),
          ),
        );
      } else if (extension == 'txt' || extension == 'xml') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextViewerPage(filePath: file.path),
          ),
        );
      } else if (extension == 'pdf') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(filePath: file.path),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported file format.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _uploadDocumentManually() async {
    List<Map<String, dynamic>> documentTypes = [];
    try {
      final response = await _documentService.fetchDocumentTypes();
      documentTypes = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch document types: $e')),
      );
      return;
    }

    int? selectedDocumentTypeId = await showDialog<int>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Document Type',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: documentTypes.length,
                    itemBuilder: (context, index) {
                      final type = documentTypes[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(
                            type['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () => Navigator.pop(context, type['id']),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDocumentTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document type selection canceled')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);

      setState(() => _isLoading = true);

      bool success = await _documentService.uploadDocument(
        file: file,
        documentName: file.path.split('/').last,
        projectId: widget.projectId,
        documentTypeId: selectedDocumentTypeId,
      );

      setState(() => _isLoading = false);

      if (success) {
        _loadDocuments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File upload failed')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File selection canceled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.green),
        )
            : _documents.isEmpty
            ? const Center(
          child: Text(
            'No documents found.',
            style: TextStyle(color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: _documents.length,
          itemBuilder: (context, index) {
            final document = _documents[index];
            return Card(
              color: Colors.grey[800],
              child: ListTile(
                title: Text(
                  document.documentName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Uploaded on: ${DateFormat('yyyy-MM-dd HH:mm').format(document.uploadedAt)}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_rounded, color: Colors.blueAccent),
                      onPressed: () => _viewFile(document.fileUrl, document.documentName),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.green),
                      onPressed: () =>
                          _downloadPDF(document.fileUrl, document.documentName),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // Add floating action button for uploading files
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadDocumentManually,
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        tooltip: 'Upload Document',
      ),
      // Add bottom navigation bar for navigation
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
