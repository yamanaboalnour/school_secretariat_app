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

  static const String volumeNumber = '٢٢';

  static const String secretaryName = 'أنس أبو شامة';
  static const String principalName = 'معاذ نعمان';

  final AcademicSequenceCsvService _service = AcademicSequenceCsvService();

  final TextEditingController _searchController = TextEditingController();

  List<AcademicStudent> _students = [];
  List<AcademicStudent> _filteredStudents = [];

  AcademicStudent? _selectedStudent;

  bool _loading = true;
  String? _error;

  int _documentSerial = 1;
  bool _printing = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterStudents);

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

      if (!mounted) return;

      setState(() {
        _students = students;
        _filteredStudents = students;
        _loading = false;

        if (students.isNotEmpty) {
          _selectedStudent = students.first;
        }
      });

      await _loadNextSerial();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadNextSerial() async {
    try {
      final nextSerial = await AcademicSequencePdfService.peekNextSerial();

      if (!mounted) return;

      setState(() {
        _documentSerial = nextSerial;
      });
    } catch (_) {
      // في حال لم تكن خدمة التسلسل جاهزة بعد،
      // نبقي الرقم الافتراضي.
    }
  }

  void _filterStudents() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredStudents = _students;
      });
      return;
    }

    final filtered = _students.where((student) {
      final name = student.fullName.toLowerCase();

      final number = student.studentNumber.toLowerCase();

      return name.contains(query) || number.contains(query);
    }).toList();

    setState(() {
      _filteredStudents = filtered;
    });
  }

  void _selectStudent(AcademicStudent student) {
    setState(() {
      _selectedStudent = student;
    });
  }

  Future<void> _print() async {
    final student = _selectedStudent;

    if (student == null || _printing) {
      return;
    }

    setState(() {
      _printing = true;
    });

    try {
      await AcademicSequencePdfService.printTranscript(
        student,
      );

      await _loadNextSerial();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تجهيز وثيقة ${student.fullName} للطباعة.',
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
    } finally {
      if (mounted) {
        setState(() {
          _printing = false;
        });
      }
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
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذر قراءة ملفات البيانات:\n$_error',
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
                    'اختر طالبًا لعرض الوثيقة',
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
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'اختيار الطالب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الرقم',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.clear,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _filteredStudents.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];

                        final selected = identical(
                          student,
                          _selectedStudent,
                        );

                        return ListTile(
                          selected: selected,
                          leading: CircleAvatar(
                            child: Text(
                              student.studentNumber,
                            ),
                          ),
                          title: Text(
                            student.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'رقم الطالب: ${student.studentNumber}',
                          ),
                          onTap: () {
                            _selectStudent(student);
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
              padding: const EdgeInsets.all(20),
              child: _buildPaperPreview(student),
            ),
          ),
        ),
        _buildBottomBar(student),
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
          maxWidth: 1100,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black87,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
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
              width: 2,
              margin: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              color: Colors.black87,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDocumentHeader(),
          const SizedBox(height: 10),
          const Text(
            'وثيقة تسلسل دراسي',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _buildStudentInfo(student),
          const SizedBox(height: 8),
          const Text(
            'قضى الأعوام التالية في ثانويتنا:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildAcademicTable(student),
          ),
          const SizedBox(height: 10),
          _buildLeavingStatement(),
          const Spacer(),
          _buildSignatures(),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: const [
              Text(
                'الجمهورية العربية السورية',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'وزارة الأوقاف',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'مديرية الأوقاف في محافظة دمشق',
                style: TextStyle(
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                schoolName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'الرقم المتسلسل: $_documentSerial',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'رقم الجلد: $volumeNumber',
              style: const TextStyle(
                fontSize: 10,
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
              child: _infoText(
                'إن الطالب',
                student.fullName,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoText(
                'المولود في',
                '........................',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _infoText(
                'بتاريخ',
                '....................',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoText(
                'رقم الطالب',
                student.studentNumber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoText(
    String label,
    String value,
  ) {
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTable(
    AcademicStudent student,
  ) {
    const int rowCount = 7;

    return Table(
      border: TableBorder.all(
        color: Colors.black87,
        width: 0.7,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(
          children: [
            _TableHeader(
              text: 'العام الدراسي',
            ),
            _TableHeader(
              text: 'في الصف',
            ),
            _TableHeader(
              text: 'النتيجة',
            ),
          ],
        ),
        for (int i = 0; i < rowCount; i++)
          TableRow(
            children: [
              _tableCell(
                i < student.records.length
                    ? _formatAcademicYear(
                        student.records[i].academicYear,
                      )
                    : '',
              ),
              _tableCell(
                i < student.records.length ? student.records[i].grade : '',
              ),
              _tableCell(
                i < student.records.length
                    ? '${student.records[i].status} / ${student.records[i].grade}'
                    : '',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLeavingStatement() {
    final now = DateTime.now();

    final date =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    return Text(
      'وتركت الثانوية بتاريخ: $date   والبيان أعطي هذه الوثيقة بناءً عليه.',
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSignatures() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _signature(
            'أمين السر',
            secretaryName,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _signature(
            'المدير',
            principalName,
          ),
        ),
      ],
    );
  }

  Widget _signature(
    String title,
    String name,
  ) {
    return Column(
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'الاسم: $name',
          style: const TextStyle(
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'التوقيع والخاتم الرسمي',
          style: TextStyle(
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    AcademicStudent student,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'الرقم: ${student.studentNumber}',
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _printing ? null : _print,
            icon: _printing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.print,
                  ),
            label: Text(
              _printing ? 'جاري تجهيز الوثيقة...' : 'طباعة الوثيقة',
            ),
          ),
        ],
      ),
    );
  }

  String _formatAcademicYear(
    String value,
  ) {
    final parts = value.split('-');

    if (parts.length != 2) {
      return value;
    }

    return '${parts[1]} / ${parts[0]} م';
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

Widget _tableCell(String text) {
  return Container(
    height: 27,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 2,
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 9,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
