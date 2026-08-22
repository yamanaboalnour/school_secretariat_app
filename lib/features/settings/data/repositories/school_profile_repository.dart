import '../../../../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/school_profile_model.dart';

class SchoolProfileRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<SchoolProfileModel> getProfile() async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'school_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return const SchoolProfileModel(
        schoolName: '',
        governorate: '',
        directorName: '',
        secretaryName: '',
      );
    }
    return SchoolProfileModel.fromMap(rows.first);
  }

  Future<void> saveProfile(SchoolProfileModel profile) async {
    final database = await _databaseHelper.database;
    await database.insert(
      'school_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
