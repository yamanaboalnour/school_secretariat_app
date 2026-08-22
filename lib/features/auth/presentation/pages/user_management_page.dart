import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/models/auth_user_model.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AuthService _authService = AuthService();
  late Future<List<AuthUserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _reloadUsers();
  }

  void _reloadUsers() {
    _usersFuture = _authService.getUsers();
  }

  Future<void> _showCreateUserDialog() async {
    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    final passwordController = TextEditingController();
    var role = 'SECRETARY';

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة مستخدم'),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration:
                        const InputDecoration(labelText: 'اسم المستخدم'),
                  ),
                  TextField(
                    controller: fullNameController,
                    decoration:
                        const InputDecoration(labelText: 'الاسم الكامل'),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور (8 محارف على الأقل)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'الصلاحية'),
                    items: const [
                      DropdownMenuItem(
                          value: 'SECRETARY', child: Text('أمين سر')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('مدير')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => role = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await _authService.createUser(
                    username: usernameController.text,
                    fullName: fullNameController.text,
                    password: passwordController.text,
                    role: role,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (error) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('تعذر إنشاء المستخدم: $error')),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    usernameController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    if (created == true && mounted) {
      setState(_reloadUsers);
    }
  }

  Future<void> _showChangePasswordDialog(AuthUserModel user) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmedController = TextEditingController();

    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('تغيير كلمة مرور ${user.username}'),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'كلمة المرور الحالية'),
              ),
              TextField(
                controller: newController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'كلمة المرور الجديدة'),
              ),
              TextField(
                controller: confirmedController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور الجديدة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (newController.text != confirmedController.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('كلمتا المرور غير متطابقتين.')),
                );
                return;
              }
              try {
                await _authService.changePassword(
                  username: user.username,
                  currentPassword: currentController.text,
                  newPassword: newController.text,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('تعذر تغيير كلمة المرور: $error')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    currentController.dispose();
    newController.dispose();
    confirmedController.dispose();
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح.')),
      );
    }
  }

  Future<void> _toggleUser(AuthUserModel user, bool isActive) async {
    try {
      await _authService.setUserActive(user.id, isActive);
      if (mounted) setState(_reloadUsers);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحديث حالة المستخدم: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<List<AuthUserModel>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text(user.username[0].toUpperCase())),
                    title: Text(user.fullName),
                    subtitle: Text('${user.username} - ${user.role}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.lock_reset),
                          tooltip: 'تغيير كلمة المرور',
                          onPressed: () => _showChangePasswordDialog(user),
                        ),
                        Switch(
                          value: user.isActive,
                          onChanged: user.username == 'admin'
                              ? null
                              : (value) => _toggleUser(user, value),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مستخدم'),
      ),
    );
  }
}
