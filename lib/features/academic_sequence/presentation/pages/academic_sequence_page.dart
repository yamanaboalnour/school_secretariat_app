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
  static const String schoolName =
      'ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين';

  static const String volumeNumber = '26';

  static const String secretaryName = 'أنس أبو شامة';

  static const String principalName = 'معاذ نعمان';

  final AcademicSequenceCsvService _service = AcademicSequenceCsvService();

  final TextEditingController _searchController = TextEditingController();

  List<AcademicStudent> _students = [];
  List<AcademicStudent> _filteredStudents = [];

  AcademicStudent? _selectedStudent;

  bool _loading = true;
  String? _error;

  int _nextSerial = 1;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _filterStudents,
    );

    _load();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filterStudents)
      ..dispose();

    super.dispose();
  }

  Future<void> _load() async {
    try {
      final students = await _service.loadStudents();

      final serial = await AcademicSequencePdfService.peekNextSerial();

      if (!mounted) return;

      setState(() {
        _students = students;
        _filteredStudents = students;
        _selectedStudent = students.isNotEmpty ? students.first : null;

        _nextSerial = serial;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? _students
        : _students.where((student) {
            return student.fullName.toLowerCase().contains(query) ||
                student.studentNumber.toLowerCase().contains(query);
          }).toList();

    setState(() {
      _filteredStudents = filtered;
    });
  }

  void _selectStudent(
    AcademicStudent student,
  ) {
    setState(() {
      _selectedStudent = student;
    });
  }

  Future<void> _print() async {
    final student = _selectedStudent;

    if (student == null) {
      return;
    }

    try {
      await AcademicSequencePdfService.printTranscript(
        student,
      );

      final next = await AcademicSequencePdfService.peekNextSerial();

      if (!mounted) return;

      setState(() {
        _nextSerial = next;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تجهيز الوثيقة للطباعة. الرقم المستخدم: ${next - 1}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر طباعة الوثيقة: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      appBar: AppBar(
        title: const Text(
          'التسلسل الدراسي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذر قراءة البيانات:\n$_error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _buildStudentPanel(),
        ),
        Expanded(
          child: _selectedStudent == null
              ? const Center(
                  child: Text(
                    'اختر طالبًا',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : _buildPreviewArea(
                  _selectedStudent!,
                ),
        ),
      ],
    );
  }

  Widget _buildStudentPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'اختيار الطالب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                0,
                12,
                12,
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'الاسم أو الرقم',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(
              height: 1,
            ),
            Expanded(
              child: _filteredStudents.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final student = _filteredStudents[index];

                        final selected = identical(
                          student,
                          _selectedStudent,
                        );

                        return ListTile(
                          selected: selected,
                          title: Text(
                            student.fullName,
                          ),
                          subtitle: Text(
                            'الرقم: ${student.studentNumber}',
                          ),
                          onTap: () {
                            _selectStudent(
                              student,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea(
    AcademicStudent student,
  ) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                20,
              ),
              child: _buildPaperPreview(
                student,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'الطالب: ${student.fullName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'الرقم المتسلسل القادم: $_nextSerial',
              ),
              const SizedBox(width: 20),
              FilledButton.icon(
                onPressed: _print,
                icon: const Icon(Icons.print),
                label: const Text(
                  'طباعة الوثيقة',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaperPreview(
    AcademicStudent student,
  ) {
    return AspectRatio(
      aspectRatio: 297 / 210,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 1200,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              spreadRadius: 2,
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildDocumentHalf(
                student,
              ),
            ),
            Container(
              width: 1.5,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              color: Colors.black,
            ),
            Expanded(
              child: _buildDocumentHalf(
                student,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentHalf(
    AcademicStudent student,
  ) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          const Text(
            'وثيقة تسلسل دراسي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStudentInfo(
            student,
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'قضى الأعوام التالية في ثانويتنا:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildAcademicTable(
              student,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'وتركت الثانوية بتاريخ: ${_today()} والبيان أعطي هذه الوثيقة بناءً عليه.',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSignatures(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: const [
              Text(
                'الجمهورية العربية السورية',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'وزارة الأوقاف',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'مديرية الأوقاف في محافظة دمشق',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
              Text(
                schoolName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'الرقم المتسلسل: $_nextSerial',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'رقم المجلد: $volumeNumber',
              style: const TextStyle(
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentInfo(
    AcademicStudent student,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _info(
                'إن الطالب',
                student.fullName,
              ),
            ),
            Expanded(
              child: _info(
                'بن',
                student.fatherName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _info(
                'المولود في',
                student.birthPlace,
              ),
            ),
            Expanded(
              child: _info(
                'بتاريخ',
                student.birthDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _info(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value.isEmpty ? '................' : value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicTable(
    AcademicStudent student,
  ) {
    const rowCount = 7;

    return Table(
      border: TableBorder.all(
        color: Colors.black,
        width: 0.7,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.6),
      },
      children: [
        const TableRow(
          children: [
            _HeaderCell(
              'العام الدراسي',
            ),
            _HeaderCell(
              'في الصف',
            ),
            _HeaderCell(
              'النتيجة',
            ),
          ],
        ),
        for (int i = 0; i < rowCount; i++)
          TableRow(
            children: [
              _DataCell(
                i < student.records.length
                    ? _formatYear(
                        student.records[i].academicYear,
                      )
                    : '',
              ),
              _DataCell(
                i < student.records.length ? student.records[i].grade : '',
              ),
              _DataCell(
                i < student.records.length ? student.records[i].status : '',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSignatures() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text(
                'أمين السر',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                secretaryName,
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'التوقيع',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Text(
                'المدير',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                principalName,
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'التوقيع والخاتم الرسمي',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatYear(
    String value,
  ) {
    final parts = value.split('-');

    if (parts.length != 2) {
      return value;
    }

    return '${parts[1]} / ${parts[0]} م';
  }

  String _today() {
    final now = DateTime.now();

    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;

  const _DataCell(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 29,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
