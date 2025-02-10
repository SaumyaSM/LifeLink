import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';

class MedicalTestsWidget extends StatefulWidget {
  final String statusLabel;
  final Color activeColor;
  final Color buttonColor;
  final Function(String, bool) onStatusChange;
  final Function(String, String?) onFileUpload;

  MedicalTestsWidget({
    Key? key,
    required this.statusLabel,
    required this.onStatusChange,
    required this.onFileUpload,
    this.activeColor = kPinkColor,
    this.buttonColor = kOrangeColor,
  }) : super(key: key);

  @override
  State<MedicalTestsWidget> createState() => _MedicalTestsWidgetState();
}

class _MedicalTestsWidgetState extends State<MedicalTestsWidget> {
  bool isCompleted = false;
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
      widget.onFileUpload(widget.statusLabel, _fileName);
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
              Text(
                widget.statusLabel,
                style: TextStyle(fontSize: 15),
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
                  'File Uploaded: ${_fileName!.split('/').last}',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
          ]
        ],
      ),
    );
  }
}
