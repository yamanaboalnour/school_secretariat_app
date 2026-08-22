import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

// --- Events ---
abstract class StudentEvent {}

class LoadStudentsEvent extends StudentEvent {
  final String query;
  LoadStudentsEvent({this.query = ''});
}

class AddStudentEvent extends StudentEvent {
  final StudentModel student;
  AddStudentEvent(this.student);
}

class DeleteStudentEvent extends StudentEvent {
  final int id;
  DeleteStudentEvent(this.id);
}

// --- States ---
abstract class StudentState {}

class StudentInitialState extends StudentState {}
class StudentLoadingState extends StudentState {}
class StudentLoadedState extends StudentState {
  final List<StudentModel> students;
  StudentLoadedState(this.students);
}
class StudentErrorState extends StudentState {
  final String message;
  StudentErrorState(this.message);
}

// --- BLoC ---
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;

  StudentBloc(this.repository) : super(StudentInitialState()) {
    on<LoadStudentsEvent>((event, emit) async {
      emit(StudentLoadingState());
      try {
        final students = await repository.getStudents(query: event.query);
        emit(StudentLoadedState(students));
      } catch (e) {
        emit(StudentErrorState('فشل في تحميل بيانات الطلاب: ${e.toString()}'));
      }
    });

    on<AddStudentEvent>((event, emit) async {
      try {
        await repository.insertStudent(event.student);
        add(LoadStudentsEvent());
      } catch (e) {
        emit(StudentErrorState('فشل في إضافة الطالب: ${e.toString()}'));
      }
    });

    on<DeleteStudentEvent>((event, emit) async {
      try {
        await repository.deleteStudent(event.id);
        add(LoadStudentsEvent());
      } catch (e) {
        emit(StudentErrorState('فشل في حذف الطالب: ${e.toString()}'));
      }
    });
  }
}