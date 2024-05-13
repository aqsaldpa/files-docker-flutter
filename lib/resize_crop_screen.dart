import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upload_files_widgets/api.dart';

class ResizeCropScreen extends StatefulWidget {
  final XFile? fileImg;
  const ResizeCropScreen({super.key, required this.fileImg});

  @override
  State<ResizeCropScreen> createState() => _ResizeCropScreenState();
}

class _ResizeCropScreenState extends State<ResizeCropScreen> {
  Uint8List? image;
  bool isLoading = false;
  var removedbg = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          removedbg
              ? Image.memory(image!)
              : Image.file(
                  fit: BoxFit.cover,
                  File(widget.fileImg!.path),
                ),
          if (isLoading) const LinearProgressIndicator(),
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                image = await Api.removeBackground(widget.fileImg!.path);
                setState(() {
                  removedbg = true;
                  isLoading = false;
                });
              },
              child: const Text("Remove Background"))
        ],
      ),
    );
  }
}
