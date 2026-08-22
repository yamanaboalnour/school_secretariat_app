class SchoolProfileModel {
  final int? id;
  final String schoolName;
  final String governorate;
  final String directorName;
  final String secretaryName;

  const SchoolProfileModel({
    this.id,
    required this.schoolName,
    required this.governorate,
    required this.directorName,
    required this.secretaryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 1,
      'school_name': schoolName,
      'governorate': governorate,
      'director_name': directorName,
      'secretary_name': secretaryName,
    };
  }

  factory SchoolProfileModel.fromMap(Map<String, dynamic> map) {
    return SchoolProfileModel(
      id: map['id'] as int?,
      schoolName: map['school_name'] as String? ?? '',
      governorate: map['governorate'] as String? ?? '',
      directorName: map['director_name'] as String? ?? '',
      secretaryName: map['secretary_name'] as String? ?? '',
    );
  }
}
