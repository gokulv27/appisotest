import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import '../api/document_api.dart';
import '../models/document.dart';
import '../widget/project_custom_bottom_navbar.dart';
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
      setState(() => _currentIndex = index);
      if (index == 0) {
        Navigator.pop(context);
      }
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
        // Handle image viewing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerPage(filePath: file.path),
          ),
        );
      } else if (extension == 'txt' || extension == 'xml') {
        // Handle text or XML file viewing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextViewerPage(filePath: file.path),
          ),
        );
      } else if (['xls', 'xlsx'].contains(extension)) {
        // Handle Excel file (Open with a third-party viewer or prompt download)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel viewer not implemented yet.')),
        );
      } else if (['doc', 'docx'].contains(extension)) {
        // Handle Word document (Open with a third-party viewer or prompt download)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Word viewer not implemented yet.')),
        );
      } else if (extension == 'pdf') {
        // Handle PDF viewing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(filePath: file.path),
          ),
        );
      } else {
        // Unsupported file type
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
        documentName: 'Sample Document', // Replace with dynamic name if needed
        projectId: widget.projectId,
        documentTypeId: 1, // Replace with dynamic document type if needed
      );

      setState(() => _isLoading = false);

      if (success) {
        _loadDocuments(); // Reload documents after successful upload
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
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
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
                      icon: Icon(Icons.remove_red_eye_rounded,
                          color: Colors.blueAccent),
                      onPressed: () => _viewFile(document.fileUrl, document.documentName),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download,
                          color: Colors.green),
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadDocumentManually,
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
