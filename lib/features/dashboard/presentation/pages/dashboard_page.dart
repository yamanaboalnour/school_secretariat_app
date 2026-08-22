import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/data/models/auth_user_model.dart';
import '../../../auth/presentation/pages/auth_gate.dart';
import '../../../auth/presentation/pages/user_management_page.dart';
import '../../../backup/presentation/pages/backup_page.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/presentation/pages/students_list_page.dart';
import '../../../../database/database_helper.dart';
import '../../../../core/sync/firebase_initializer.dart';
import '../../../../core/sync/repositories/sync_queue_repository.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/sync/transports/firestore_sync_transport.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;
  String? _errorMessage;
  int _studentCount = 0;
  int _gradeCount = 0;
  int _documentCount = 0;
  Map<String, int> _studentsByGrade = {};
  AuthUserModel? _currentUser;
  final SyncQueueRepository _syncQueue = SyncQueueRepository();
  int _pendingSyncCount = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadStatistics();
    _loadPendingSyncCount();
  }

  Future<void> _loadPendingSyncCount() async {
    final count = await _syncQueue.pendingCount();
    if (!mounted) return;
    setState(() => _pendingSyncCount = count);
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService().currentUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadStatistics() async {
    try {
      final database = await _databaseHelper.database;
      final studentCount = Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM students'),
          ) ??
          0;
      final gradeCount = Sqflite.firstIntValue(
            await database
                .rawQuery('SELECT COUNT(DISTINCT grade_level) FROM students'),
          ) ??
          0;
      final documentCount = Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM issued_documents'),
          ) ??
          0;
      final rows = await database.rawQuery('''
        SELECT grade_level, COUNT(*) AS student_count
        FROM students
        GROUP BY grade_level
        ORDER BY student_count DESC, grade_level ASC
      ''');

      if (!mounted) return;
      setState(() {
        _studentCount = studentCount;
        _gradeCount = gradeCount;
        _documentCount = documentCount;
        _studentsByGrade = {
          for (final row in rows)
            (row['grade_level'] as String? ?? 'غير محدد'):
                (row['student_count'] as int? ?? 0),
        };
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل الإحصائيات: $error';
      });
    }
  }

  void _openStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              StudentBloc(StudentRepository())..add(LoadStudentsEvent()),
          child: const StudentsListPage(),
        ),
      ),
    ).then((_) => _loadStatistics());
  }

  void _openBackup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BackupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الإحصائيات',
          ),
          IconButton(
            onPressed: _isSyncing ? null : _syncNow,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Badge(
                    isLabelVisible: _pendingSyncCount > 0,
                    label: Text(_pendingSyncCount.toString()),
                    child: const Icon(Icons.sync),
                  ),
            tooltip: 'مزامنة البيانات',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
          if (_currentUser?.role == 'ADMIN')
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserManagementPage(),
                ),
              ),
              icon: const Icon(Icons.manage_accounts),
              tooltip: 'إدارة المستخدمين',
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: _loadStatistics,
          child: _buildBody(),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await FirebaseInitializer.initialize();
      final result = await SyncService(
        transport: FirestoreSyncTransport(),
      ).syncPending();
      await _loadPendingSyncCount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت المزامنة: ${result.synced} ناجحة، '
            '${result.failed} فاشلة، ${result.conflicts} تعارض.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الاتصال بالمزامنة: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(_errorMessage!)),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'ملخص الإحصائيات العامة',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 24) / 3;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  width: cardWidth,
                  title: 'إجمالي الطلاب',
                  value: _studentCount.toString(),
                  icon: Icons.people,
                  color: Colors.indigo,
                ),
                _buildStatCard(
                  width: cardWidth,
                  title: 'الصفوف الدراسية',
                  value: _gradeCount.toString(),
                  icon: Icons.class_,
                  color: Colors.teal,
                ),
                _buildStatCard(
                  width: cardWidth,
                  title: 'الوثائق الصادرة',
                  value: _documentCount.toString(),
                  icon: Icons.description,
                  color: Colors.deepOrange,
                ),
                _buildStatCard(
                  width: cardWidth,
                  title: 'عمليات بانتظار المزامنة',
                  value: _pendingSyncCount.toString(),
                  icon: Icons.cloud_upload,
                  color: Colors.blueGrey,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Text(
          'توزيع الطلاب حسب الصف',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (_studentsByGrade.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('لا توجد بيانات طلاب لعرض التوزيع.'),
            ),
          )
        else
          ..._studentsByGrade.entries.map(_buildGradeBar),
        const SizedBox(height: 28),
        Text(
          'الوصول السريع',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMenuButton(
                title: 'إدارة الطلاب',
                icon: Icons.person_search,
                color: Colors.indigo,
                onTap: _openStudents,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenuButton(
                title: 'النسخ الاحتياطي',
                icon: Icons.security,
                color: Colors.teal,
                onTap: _openBackup,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeBar(MapEntry<String, int> entry) {
    final maximum = _studentsByGrade.values.reduce((a, b) => a > b ? a : b);
    final ratio = maximum == 0 ? 0.0 : entry.value / maximum;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 92, child: Text(entry.key)),
            Expanded(
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 12),
            Text(entry.value.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(title, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: BorderSide(color: color),
      ),
    );
  }
}
