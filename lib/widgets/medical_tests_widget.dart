import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';

class MedicalTestsWidget extends StatefulWidget {
  final String statusLabel;
  final bool isMandatory;
  final Color activeColor;
  final Color buttonColor;
  final Function(String, bool) onStatusChange;
  final Function(String, String?) onFileUpload;
  final Function(String, String?, String?)? onFilePathSelected;

  MedicalTestsWidget({
    Key? key,
    required this.statusLabel,
    this.isMandatory = false,
    required this.onStatusChange,
    required this.onFileUpload,
    this.onFilePathSelected,
    this.activeColor = kPinkColor,
    this.buttonColor = kOrangeColor,
  }) : super(key: key);

  @override
  State<MedicalTestsWidget> createState() => _MedicalTestsWidgetState();
}

class _MedicalTestsWidgetState extends State<MedicalTestsWidget> {
  bool isCompleted = false;
  String? _fileName;
  String? _filePath;

  // Function to detect file type based on its first few bytes
  Future<String?> _detectFileType(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.openRead(0, 8).first;

      // Check for PDF signature (%PDF)
      if (bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46) {
        return '.pdf';
      }

      // Check for JPEG signature (JFIF or Exif)
      if (bytes.length >= 3 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF) {
        return '.jpg';
      }

      // Check for PNG signature
      if (bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A) {
        return '.png';
      }

      return null;
    } catch (e) {
      print('Error detecting file type: $e');
      return null;
    }
  }

  Future<void> _pickFile() async {
    try {
      // Allow only PDF and image files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final fileName = result.files.single.name;

        // Check file size (limit to 10MB)
        final file = File(path);
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size exceeds 10MB limit'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Get detected file extension based on content
        final detectedExt = await _detectFileType(path);
        if (detectedExt == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Unsupported file format. Please upload PDF, JPG, or PNG files.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check if file extension matches content
        final lowerFileName = fileName.toLowerCase();
        if ((detectedExt == '.pdf' && !lowerFileName.endsWith('.pdf')) ||
            (detectedExt == '.jpg' &&
                !lowerFileName.endsWith('.jpg') &&
                !lowerFileName.endsWith('.jpeg')) ||
            (detectedExt == '.png' && !lowerFileName.endsWith('.png'))) {
          // Add correct extension to the filename if it doesn't match
          final correctedFileName = '$fileName$detectedExt';

          setState(() {
            _fileName = correctedFileName;
            _filePath = path;
          });

          widget.onFileUpload(widget.statusLabel, _fileName);

          if (widget.onFilePathSelected != null) {
            widget.onFilePathSelected!(
                widget.statusLabel, _fileName, _filePath);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File type corrected to $detectedExt'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // File extension matches content
          setState(() {
            _fileName = fileName;
            _filePath = path;
          });

          widget.onFileUpload(widget.statusLabel, _fileName);

          if (widget.onFilePathSelected != null) {
            widget.onFilePathSelected!(
                widget.statusLabel, _fileName, _filePath);
          }
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.statusLabel,
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.isMandatory ? Colors.red : Colors.black,
                          fontWeight: widget.isMandatory
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (widget.isMandatory)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Switch(
                value: isCompleted,
                onChanged: (value) {
                  setState(() {
                    isCompleted = value;
                  });
                  widget.onStatusChange(widget.statusLabel, isCompleted);
                },
                activeColor: widget.activeColor,
              ),
            ],
          ),
          if (isCompleted) ...[
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.upload_file),
              label: Text('Upload Report'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: widget.buttonColor,
              ),
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'File Uploaded: ${_fileName!}',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
          ]
        ],
      ),
    );
  }
}
