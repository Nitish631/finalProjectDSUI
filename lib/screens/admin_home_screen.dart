import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medicom/data/constant.dart' as constant;
import 'package:medicom/iomodels/document_model.dart';
import 'package:medicom/screens/user_interface.dart';
import 'package:medicom/services/api_document_services.dart';

class AdminHomeScreen extends StatefulWidget {
  final String email;
  final String password;

  const AdminHomeScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<DocumentModel> documents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.getDocuments(
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;

      setState(() {
        documents = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<File?> pickPdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (file == null) {
      return null;
    }

    final path = file.path;

    if (path == null) {
      return null;
    }

    return File(path);
  }

  Future<void> uploadDocument() async {
    final selectedFile = await pickPdf();

    if (selectedFile == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final message = await ApiService.uploadDocument(
        email: widget.email,
        password: widget.password,
        file: selectedFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(message),
        ),
      );

      await loadDocuments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> updateDocument(DocumentModel document) async {
    final selectedFile = await pickPdf();

    if (selectedFile == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final message = await ApiService.updateDocument(
        documentId: document.documentId,
        email: widget.email,
        password: widget.password,
        file: selectedFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(message),
        ),
      );

      await loadDocuments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> deleteDocument(DocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: constant.dimBackgroundColor,
          title: const Text(
            "Delete Document",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete "
            "${document.filename}?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: constant.backgroundColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteDocument(
        documentId: document.documentId,
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Text("Document deleted successfully"),
        ),
      );

      await loadDocuments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    }
  }

  void goToMainPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:(didPop, result){
        if(!didPop){
          goToMainPage();
        }
      },
      child: Scaffold(
        backgroundColor: constant.backgroundColor,
      
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: constant.backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Admin",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: loading ? null : loadDocuments,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
          ],
        ),
      
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 40),
          child: FloatingActionButton.extended(
            onPressed: loading ? null : uploadDocument,
            backgroundColor: constant.buttonColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              "Add PDF",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : documents.isEmpty
              ? RefreshIndicator(
                  onRefresh: loadDocuments,
                  color: constant.backgroundColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text(
                          "No PDF documents found",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDocuments,
                  color: constant.backgroundColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: constant.dimBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
      
                                  const SizedBox(width: 12),
      
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          document.filename,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
      
                                        const SizedBox(height: 6),
      
                                        Text(
                                          "Status: ${document.status}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
      
                                        const SizedBox(height: 3),
      
                                        Text(
                                          "ID: ${document.documentId}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
      
                              const SizedBox(height: 14),
      
                              const Divider(color: Colors.white24, height: 1),
      
                              const SizedBox(height: 8),
      
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: loading
                                        ? null
                                        : () => updateDocument(document),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
      
                                  const SizedBox(width: 8),
      
                                  TextButton.icon(
                                    onPressed: loading
                                        ? null
                                        : () => deleteDocument(document),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
