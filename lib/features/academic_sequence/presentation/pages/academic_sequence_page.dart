import 'package:flutter/material.dart';

import '../../data/models/academic_sequence_model.dart';
import '../../data/services/academic_sequence_csv_service.dart';
import '../../data/services/academic_sequence_pdf_service.dart';

class AcademicSequencePage extends StatefulWidget {
  const AcademicSequencePage({super.key});

  @override
  State<AcademicSequencePage> createState() => _AcademicSequencePageState();
}

class _AcademicSequencePageState extends State<AcademicSequencePage> {
  final _service = AcademicSequenceCsvService();
  final _searchController = TextEditingController();

  List<AcademicStudent> _students = [];
  AcademicStudent? _selectedStudent;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filter)
      ..dispose();

    super.dispose();
  }

  Future<void> _load() async {
    try {
      final students = await _service.loadStudents();

      if (!mounted) return;

      setState(() {
        _students = students;
        _loading = false;

        if (students.isNotEmpty) {
          _selectedStudent = students.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _filter() {
    if (!mounted) return;

    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return;
    }

    final found = _students.where((student) {
      return student.studentNumber.toLowerCase().contains(query) ||
          student.fullName.toLowerCase().contains(query);
    }).toList();

    if (found.isNotEmpty) {
      setState(() {
        _selectedStudent = found.first;
      });
    }
  }

  Future<void> _print() async {
    final student = _selectedStudent;

    if (student == null) {
      return;
    }

    await AcademicSequencePdfService.printTranscript(student);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التسلسل الدراسي'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'تعذر قراءة ملفات البيانات:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'بحث عن الطالب',
                      hintText: 'الاسم أو الرقم',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];

                      final selected = identical(student, _selectedStudent);

                      return ListTile(
                        selected: selected,
                        title: Text(student.fullName),
                        subtitle: Text(
                          'الرقم: ${student.studentNumber}',
                        ),
                        onTap: () {
                          setState(() {
                            _selectedStudent = student;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _selectedStudent == null
              ? const Center(
                  child: Text('اختر طالبًا'),
                )
              : _buildTranscript(_selectedStudent!),
        ),
      ],
    );
  }

  Widget _buildTranscript(
    AcademicStudent student,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'رقم الطالب: ${student.studentNumber}',
                    ),
                    if (student.currentGrade.isNotEmpty)
                      Text(
                        'الصف الحالي: ${student.currentGrade}',
                      ),
                    if (student.section.isNotEmpty)
                      Text(
                        'الشعبة: ${student.section}',
                      ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _print,
                icon: const Icon(Icons.print),
                label: const Text('طباعة التسلسل'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: student.records.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد نتائج دراسية لهذا الطالب.',
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text('العام الدراسي'),
                      ),
                      DataColumn(
                        label: Text('الصف'),
                      ),
                      DataColumn(
                        label: Text('النتيجة'),
                      ),
                    ],
                    rows: student.records.map((record) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(record.academicYear),
                          ),
                          DataCell(
                            Text(record.grade),
                          ),
                          DataCell(
                            Text(record.status),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
