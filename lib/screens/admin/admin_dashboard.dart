import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/file_service.dart';
import '../../services/department_service.dart';
import '../../models/app_user.dart';
import '../../models/content_file.dart';
import '../../models/department.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _fileService = FileService();
  final _departmentService = DepartmentService();
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentAppUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _uploadFile() async {
    if (_currentUser == null) return;

    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Show upload dialog
      await showDialog(
        context: context,
        builder: (context) => _UploadDialog(
          file: file,
          fileName: fileName,
          fileService: _fileService,
          currentUser: _currentUser!,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selection failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_currentUser!.fullName}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Upload and manage course materials and past exams'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ContentFile>>(
              stream: _fileService.getFilesByDepartment(_currentUser!.departmentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No files uploaded yet'),
                  );
                }

                final files = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final canEdit = file.canBeEditedBy(
                      _currentUser!.uid,
                      _currentUser!.role == UserRole.superAdmin,
                    );

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          file.contentType == ContentType.courseMaterial
                              ? Icons.book
                              : Icons.quiz,
                        ),
                        title: Text(file.fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (file.description != null)
                              Text(file.description!),
                            Text(
                              'Uploaded: ${_formatDate(file.uploadedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (!canEdit && file.uploaderId == _currentUser!.uid)
                              Text(
                                'Edit period expired',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                    ),
                              ),
                          ],
                        ),
                        trailing: canEdit
                            ? PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    await _fileService.deleteFile(file.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('File deleted'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadFile,
        icon: const Icon(Icons.upload),
        label: const Text('Upload File'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _UploadDialog extends StatefulWidget {
  final File file;
  final String fileName;
  final FileService fileService;
  final AppUser currentUser;

  const _UploadDialog({
    required this.file,
    required this.fileName,
    required this.fileService,
    required this.currentUser,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final _descriptionController = TextEditingController();
  final _departmentService = DepartmentService();
  String? _selectedDepartmentId;
  ContentType _selectedContentType = ContentType.courseMaterial;
  bool _isUploading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload to Telegram
      final telegramResponse = await widget.fileService.uploadFileToTelegram(widget.file);

      // Save metadata to Firestore
      await widget.fileService.saveFileMetadata(
        fileName: widget.fileName,
        departmentId: _selectedDepartmentId!,
        contentType: _selectedContentType,
        uploaderId: widget.currentUser.uid,
        telegramFileId: telegramResponse['telegram_file_id'],
        fileUrl: telegramResponse['file_url'],
        fileSize: telegramResponse['file_size'],
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload File'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('File: ${widget.fileName}'),
            const SizedBox(height: 16),
            StreamBuilder<List<Department>>(
              stream: _departmentService.getDepartments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final departments = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedDepartmentId,
                  items: departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartmentId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ContentType>(
              decoration: const InputDecoration(
                labelText: 'Content Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedContentType,
              items: const [
                DropdownMenuItem(
                  value: ContentType.courseMaterial,
                  child: Text('Course Material'),
                ),
                DropdownMenuItem(
                  value: ContentType.pastExam,
                  child: Text('Past Exam'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedContentType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _upload,
          child: _isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }
}
