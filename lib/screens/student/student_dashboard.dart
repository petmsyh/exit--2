import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/file_service.dart';
import '../../services/department_service.dart';
import '../../models/app_user.dart';
import '../../models/content_file.dart';
import '../../models/department.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _fileService = FileService();
  final _departmentService = DepartmentService();
  AppUser? _currentUser;
  ContentType _selectedContentType = ContentType.courseMaterial;

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

  Future<void> _downloadFile(ContentFile file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${file.fileName}';
      
      await _fileService.downloadFile(file.fileUrl, filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded: ${file.fileName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _openFile(String fileUrl) async {
    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if student is approved
    if (!_currentUser!.isApproved) {
      final timeSinceCreation = DateTime.now().difference(_currentUser!.createdAt);
      if (timeSinceCreation.inMinutes >= 5) {
        // Auto logout after 5 minutes
        Provider.of<AuthService>(context, listen: false).signOut();
        return const Scaffold(
          body: Center(
            child: Text('Your temporary access has expired. Please wait for approval.'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          if (!_currentUser!.isApproved)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Pending Approval'),
                backgroundColor: Colors.orange,
              ),
            ),
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
                FutureBuilder<Department?>(
                  future: _departmentService.getDepartmentById(_currentUser!.departmentId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Department: ${snapshot.data!.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<ContentType>(
              segments: const [
                ButtonSegment(
                  value: ContentType.courseMaterial,
                  label: Text('Course Materials'),
                  icon: Icon(Icons.book),
                ),
                ButtonSegment(
                  value: ContentType.pastExam,
                  label: Text('Past Exams'),
                  icon: Icon(Icons.quiz),
                ),
              ],
              selected: {_selectedContentType},
              onSelectionChanged: (Set<ContentType> newSelection) {
                setState(() {
                  _selectedContentType = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ContentFile>>(
              stream: _fileService.getFilesByDepartmentAndType(
                _currentUser!.departmentId,
                _selectedContentType,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No files available yet'),
                  );
                }

                final files = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
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
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => _openFile(file.fileUrl),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadFile(file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
