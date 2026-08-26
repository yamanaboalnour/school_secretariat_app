import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../documents/data/datasources/pdf_service.dart';
import '../../../students/data/models/student_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/grade_repository.dart';

class StudentGradesPage extends StatefulWidget {
  final StudentModel student;

  const StudentGradesPage({super.key, required this.student});

  @override
  State<StudentGradesPage> createState() => _StudentGradesPageState();
}

class _StudentGradesPageState extends State<StudentGradesPage> {
  final GradeRepository _repository = GradeRepository();
  List<GradeModel> _grades = [];
  bool _isLoading = true;
  String? _errorMessage;

  int? get _studentId => widget.student.id;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    if (_studentId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'لا يمكن إدارة الدرجات قبل حفظ الطالب في قاعدة البيانات.';
      });
      return;
    }

    try {
      final grades = await _repository.getStudentGrades(_studentId!);
      if (!mounted) return;
      setState(() {
        _grades = grades;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الدرجات: $error';
      });
    }
  }

  Future<void> _saveGrade(GradeModel grade) async {
    try {
      await _repository.saveGrade(grade);
      await _loadGrades();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ العلامات بنجاح.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ العلامات: $error')),
      );
    }
  }

  Future<void> _deleteGrade(GradeModel grade) async {
    final id = grade.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المادة'),
        content: Text('هل تريد حذف علامات مادة ${grade.subjectName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _repository.deleteGrade(id);
      await _loadGrades();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حذف المادة: $error')),
      );
    }
  }

  Future<void> _showGradeDialog({GradeModel? grade}) async {
    final subjectController = TextEditingController(text: grade?.subjectName);
    final firstTermController = TextEditingController(
      text: grade == null ? '' : grade.firstTerm.toString(),
    );
    final secondTermController = TextEditingController(
      text: grade == null ? '' : grade.secondTerm.toString(),
    );

    final result = await showDialog<GradeModel>(
      context: context,
      builder: (dialogContext) {
        String? validationMessage;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(grade == null ? 'إضافة مادة' : 'تعديل العلامات'),
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(labelText: 'اسم المادة'),
                  ),
                  TextField(
                    controller: firstTermController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'درجة الفصل الأول'),
                  ),
                  TextField(
                    controller: secondTermController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'درجة الفصل الثاني'),
                  ),
                  if (validationMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        validationMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final subject = subjectController.text.trim();
                  final firstTerm = double.tryParse(firstTermController.text);
                  final secondTerm = double.tryParse(secondTermController.text);
                  if (subject.isEmpty ||
                      firstTerm == null ||
                      secondTerm == null ||
                      firstTerm < 0 ||
                      firstTerm > 100 ||
                      secondTerm < 0 ||
                      secondTerm > 100) {
                    setDialogState(() {
                      validationMessage = 'أدخل مادة وعلامات صحيحة بين 0 و100.';
                    });
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    GradeModel(
                      id: grade?.id,
                      studentId: _studentId!,
                      subjectName: subject,
                      firstTerm: firstTerm,
                      secondTerm: secondTerm,
                    ),
                  );
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );

    subjectController.dispose();
    firstTermController.dispose();
    secondTermController.dispose();

    if (result != null) {
      await _saveGrade(result);
    }
  }

  void _previewReportCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('معاينة الجلاء المدرسي')),
          body: PdfPreview(
            build: (format) => PdfService.generateReportCard(
              student: widget.student,
              grades: _grades,
            ),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'علامات الطالب: ${widget.student.firstName} ${widget.student.lastName}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'طباعة الجلاء المدرسي',
            onPressed: _grades.isEmpty ? null : _previewReportCard,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBody(),
      ),
      floatingActionButton: _studentId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showGradeDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مادة'),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_grades.isEmpty) {
      return const Center(child: Text('لا توجد علامات مسجلة لهذا الطالب.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final grade = _grades[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              grade.subjectName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'الفصل الأول: ${grade.firstTerm} | الفصل الثاني: ${grade.secondTerm}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المجموع: ${grade.total}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'تعديل العلامات',
                  onPressed: () => _showGradeDialog(grade: grade),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف المادة',
                  onPressed: () => _deleteGrade(grade),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
