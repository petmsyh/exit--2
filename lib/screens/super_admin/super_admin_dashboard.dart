import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/department_service.dart';
import '../../services/file_service.dart';
import '../../models/app_user.dart';
import '../../models/department.dart';
import '../../models/content_file.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final _departmentService = DepartmentService();
  final _fileService = FileService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _UsersManagementTab(),
          _DepartmentsManagementTab(),
          _FilesManagementTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Departments',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
        ],
      ),
    );
  }
}

// Users Management Tab
class _UsersManagementTab extends StatelessWidget {
  const _UsersManagementTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users = snapshot.data!.docs
            .map((doc) => AppUser.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  user.role == UserRole.superAdmin
                      ? Icons.admin_panel_settings
                      : user.role == UserRole.admin
                          ? Icons.manage_accounts
                          : Icons.person,
                  color: user.isApproved ? Colors.green : Colors.orange,
                ),
                title: Text(user.fullName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text('Role: ${user.role.name}'),
                    if (!user.isApproved)
                      Text(
                        'Pending Approval',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: user.role == UserRole.student && !user.isApproved
                    ? ElevatedButton(
                        onPressed: () async {
                          final authService =
                              Provider.of<AuthService>(context, listen: false);
                          await authService.approveStudent(user.uid);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Approved ${user.fullName}'),
                              ),
                            );
                          }
                        },
                        child: const Text('Approve'),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

// Departments Management Tab
class _DepartmentsManagementTab extends StatelessWidget {
  const _DepartmentsManagementTab();

  @override
  Widget build(BuildContext context) {
    final departmentService = DepartmentService();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddDepartmentDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Department'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Department>>(
            stream: departmentService.getDepartments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No departments found'));
              }

              final departments = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final dept = departments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(dept.name),
                      subtitle: Text(dept.description),
                      trailing: PopupMenuButton(
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
                            await departmentService.deleteDepartment(dept.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Department deleted'),
                                ),
                              );
                            }
                          } else if (value == 'edit') {
                            _showEditDepartmentDialog(context, dept);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDepartmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              final currentUser = await authService.getCurrentAppUser();
              
              if (currentUser != null) {
                final departmentService = DepartmentService();
                await departmentService.createDepartment(
                  name: nameController.text,
                  description: descriptionController.text,
                  createdBy: currentUser.uid,
                );
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Department created')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDepartmentDialog(BuildContext context, Department dept) {
    final nameController = TextEditingController(text: dept.name);
    final descriptionController = TextEditingController(text: dept.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final departmentService = DepartmentService();
              await departmentService.updateDepartment(
                id: dept.id,
                name: nameController.text,
                description: descriptionController.text,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Department updated')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

// Files Management Tab
class _FilesManagementTab extends StatelessWidget {
  const _FilesManagementTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('files')
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No files found'));
        }

        final files = snapshot.data!.docs
            .map((doc) => ContentFile.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
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
                    if (file.description != null) Text(file.description!),
                    Text('Uploaded: ${_formatDate(file.uploadedAt)}'),
                    Text('Type: ${file.contentType.name}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text('Delete ${file.fileName}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      final fileService = FileService();
                      await fileService.deleteFile(file.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File deleted')),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
