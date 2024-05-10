// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tus_client_dart/tus_client_dart.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  XFile? _file;
  XFile? _filePdf;
  TusClient? client;
  late PDFViewController pdfViewController;

  Future<void> uploadToTusClient(XFile filesUpload) async {
    print("Create a client");

    client = TusClient(
      filesUpload,
      store: TusMemoryStore(),
    );
    print("Starting upload");
    await client!.upload(
      onStart: (TusClient client, Duration? estimation) {
        print(estimation);
      },
      onComplete: () async {
        print("Completed!");
        Navigator.pop(context);
      },
      onProgress: (progress, estimate) {
        print("Progress: $progress");
        print('Estimate: $estimate');
      },
      uri: Uri.parse("http://192.168.1.4:55000/files/"),
      metadata: {
        'testMetaData': 'testMetaData',
        'testMetaData2': 'testMetaData2',
      },
      headers: {
        'testHeaders': 'testHeaders',
        'testHeaders2': 'testHeaders2',
      },
      measureUploadSpeed: true,
    );
  }

  Future<void> openPhotos() async {
    try {
      _file = await ImagePicker().pickImage(source: ImageSource.camera);
      if (_file == null) return;
      print(_file!.path.toString());
      showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              backgroundColor: Colors.grey,
              title: const Text("Preview Foto"),
              content: Wrap(
                children: [
                  Center(
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height / 4,
                      child: Image.file(
                        File(_file!.path),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "BATAL",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    uploadToTusClient(_file!);
                  },
                  child: const Text(
                    "KIRIM",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          }));
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to pick _file : $e');
      }
    }
  }

  Future<void> openDoc() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (result != null) {
      _filePdf = XFile(result.files.single.path ?? "");
      if (mounted)
        showDialog(
            context: context,
            builder: ((context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("File"),
                content: Wrap(
                  children: [
                    Center(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height / 4,
                        child: PDFView(
                          filePath: result.files.single.path,
                          autoSpacing: true,
                          enableSwipe: true,
                          pageSnap: true,
                          swipeHorizontal: true,
                          onError: (error) {
                            print(error);
                          },
                          onPageError: (page, error) {
                            print('$page: ${error.toString()}');
                          },
                          onViewCreated: (PDFViewController vc) {
                            pdfViewController = vc;
                          },
                          onPageChanged: (int? page, int? total) {
                            print('page change: $page/$total');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "BATAL",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      uploadToTusClient(_filePdf!);
                    },
                    child: const Text(
                      "KIRIM",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                openPhotos();
              },
              child: const Text("Upload Photos "),
            ),
            ElevatedButton(
              onPressed: () {
                openDoc();
              },
              child: const Text("Upload File Pdf "),
            ),
          ],
        ),
      ),
    );
  }
}
