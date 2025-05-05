import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DocumentViewer extends StatefulWidget {
  final String url;
  final String testName;

  const DocumentViewer({
    Key? key,
    required this.url,
    required this.testName,
  }) : super(key: key);

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  bool _isLoading = true;
  String? _filePath;
  String _fileType = "unknown";
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Improved file type detection
      final url = widget.url.toLowerCase();

      if (url.endsWith('.pdf') ||
          url.contains('/pdf') ||
          url.contains('application/pdf')) {
        _fileType = 'pdf';
      } else if (url.endsWith('.jpg') ||
          url.endsWith('.jpeg') ||
          url.contains('/jpeg') ||
          url.contains('image/jpeg')) {
        _fileType = 'image';
      } else if (url.endsWith('.png') ||
          url.contains('/png') ||
          url.contains('image/png')) {
        _fileType = 'image';
      } else {
        // Try to determine by content-type header
        try {
          final response = await http.head(Uri.parse(widget.url));
          final contentType = response.headers['content-type'];
          if (contentType != null) {
            if (contentType.contains('pdf')) {
              _fileType = 'pdf';
            } else if (contentType.contains('image')) {
              _fileType = 'image';
            }
          }
        } catch (e) {
          print("Error determining content type: $e");
          // Use extension as fallback
          if (url.contains('.')) {
            final extension = url.split('.').last;
            if (['jpg', 'jpeg', 'png'].contains(extension)) {
              _fileType = 'image';
            } else if (extension == 'pdf') {
              _fileType = 'pdf';
            }
          }
        }
      }

      // For PDFs, we need to download the file locally to view it
      if (_fileType == 'pdf') {
        final response = await http.get(Uri.parse(widget.url));

        if (response.statusCode == 200) {
          final dir = await getTemporaryDirectory();
          final file =
              File('${dir.path}/${widget.testName.replaceAll(' ', '_')}.pdf');
          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            _filePath = file.path;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to download PDF: ${response.statusCode}';
            _isLoading = false;
          });
        }
      } else if (_fileType == 'image') {
        // For images, we can use network image directly
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Unsupported document type';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading document: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.testName} Document"),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final Uri url = Uri.parse(widget.url);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Could not open document externally')),
                );
              }
            },
            tooltip: "Open in browser",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading document..."),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadDocument,
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : _buildDocumentView(),
    );
  }

  Widget _buildDocumentView() {
    if (_fileType == 'pdf' && _filePath != null) {
      return PDFView(
        filePath: _filePath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
        onPageError: (page, error) {
          setState(() {
            _errorMessage = 'Error on page $page: $error';
          });
        },
      );
    } else if (_fileType == 'image') {
      return Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            widget.url,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("Failed to load image: $error",
                      textAlign: TextAlign.center),
                ],
              );
            },
          ),
        ),
      );
    } else {
      return const Center(
        child: Text("Unsupported document type"),
      );
    }
  }
}
