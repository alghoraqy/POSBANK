import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task/Network/remote/dio_helper.dart';
import 'package:task/bloc/Notes/notes_states.dart';
import 'package:task/models/interest_model.dart';
import 'package:task/models/note_model.dart';
import 'package:task/models/user_model.dart';

class NotesCubit extends Cubit<NotesStates> {
  NotesCubit() : super(NotesInitState());

  static NotesCubit get(context) => BlocProvider.of(context);

  var formKey = GlobalKey<FormState>();
  var formKey2 = GlobalKey<FormState>();

  /////Search
  TextEditingController searchController = TextEditingController();
  ////Add User
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  ////EditNote
  TextEditingController editNoteController = TextEditingController();

  /// Add Note
  TextEditingController noteTextController = TextEditingController();
  TextEditingController noteDateTimeController = TextEditingController();

  ///
  static List<String> dropDownItem = ['Football', 'Tennis', 'Tv', 'Movies'];
  String? selectedInterest;

  void changeSelectedVal(value) {
    selectedInterest = value;
    emit(ChangeSelectedValue());
  }

  bool isSecure = true;
  void changevisibilty() {
    isSecure = !isSecure;
    emit(ChangeVisibilty());
  }

  bool isSearch = false;

  void changeSearch() {
    isSearch = true;
    emit(ChangeSearch());
  }

  void closeSearch() {
    isSearch = false;
    emit(ChangeSearch());
  }

  bool changedataSource = false;
  void changeDataSource(bool value) {
    changedataSource = value;
    emit(ChangeDataSource());
  }

/////// API Calling
  //AllNotes
  List<NoteModel>? notesList;
  Future getAllNotes() async {
    emit(GetAllNotesLoading());
    return await DioHelper.getData(path: 'notes/getall').then((value) {
      notesList =
          (value.data as List).map((i) => NoteModel.fromJson(i)).toList();
      emit(GetAllNotesSuccess());
    }).catchError((error) {
      print(error.toString());
      emit(GetAllNotesError(error: error.toString()));
    });
  }

//AllUsers
  List<UserModel>? usersList;
  List<String>? usersName;
  Map<String, String> userIdname = {};
  Future getAllUsers() async {
    return await DioHelper.getData(path: 'users/getall').then((value) {
      usersList =
          (value.data as List).map((i) => UserModel.fromJson(i)).toList();
      usersName = usersList!.map((e) {
        return e.username;
      }).toList();
      usersList!.forEach((element) {
        userIdname.addEntries([MapEntry(element.id, element.username)]);
      });
      print(usersName);
      print(userIdname);

      emit(GetAllUsersSuccess());
    }).catchError((error) {
      print(error.toString());
      emit(GetAllUsersError(error: error.toString()));
    });
  }

  ///UPDATE NOTE
  String? responseText;
  String selectedUserID = '0';
  void updateNote({
    required String id,
    required String text,
    required String userId,
    String? date,
  }) {
    DioHelper.postData(
      path: 'notes/update',
      data: {
        'Id': id,
        'Text': text,
        'UserId': userId,
        'PlaceDateTime': DateFormat("yyy-MM-dd'T'hh:mm:ss")
            .format(DateTime.now())
            .toString(),
      },
    ).then((value) {
      responseText = value.data;
      print(
        DateFormat("yyy-MM-dd'T'hh:mm:ss").format(DateTime.now()),
      );
      emit(UpdateNotesSuccess(message: responseText!));
    }).catchError((error) {
      print(error.toString());
      print(
        DateFormat("yyy-MM-dd'T'hh:mm:ss").format(DateTime.now()),
      );
      emit(UpdateNotesError(error: error.toString()));
    });
  }

  void changeAssignUser(value) {
    selectedUserID = value;
    emit(ChangeSelectedValue());
  }

  //Get All Interest

  List<InterestModel>? interestModel;
  void getAllInteres() {
    DioHelper.getData(path: 'intrests/getall').then((value) {
      interestModel =
          (value.data as List).map((i) => InterestModel.fromJson(i)).toList();
      emit(GetAllInterestsSuccess());
    }).catchError((error) {
      emit(GetAllInterestsError());
      print(error.toString());
    });
  }

  //Add User
  void addUser({
    required String userName,
    required String password,
    required String email,
    required dynamic image,
    required String intrestId,
  }) {
    emit(AddUserLoading());
    DioHelper.postData(path: 'users/insert', data: {
      'Username': userName,
      'Password': password,
      'Email': email,
      'ImageAsBase64': image,
      'IntrestId': intrestId,
    }).then((value) {
      emit(AddUserSuccess(message: value.data));
    }).catchError((error) {
      print(error.toString());
      emit(AddUserError(error: error.toString()));
    });
  }

  //SEARCH BY TEXT

  List<NoteModel>? searchednotes;
  void searchByText(String query) {
    final suggestiong = notesList!.where((note) {
      final noteTitle = note.text.toLowerCase();
      final input = query.toLowerCase();
      return noteTitle.contains(input);
    }).toList();
    searchednotes = suggestiong;
    emit(SearchBytText());
  }

  //SEARCH BY User ID

  List<NoteModel>? searchedbyUserIdnotes;
  void searchByUserID(String query) {
    final suggestiong = notesList!.where((note) {
      final noteUserId = note.userId;
      final input = query;
      return noteUserId.contains(input);
    }).toList();
    searchedbyUserIdnotes = suggestiong;
    emit(SearchBytText());
  }

  //Add Note
  Future addNote({
    required String text,
    required String userId,
  }) async {
    emit(AddNoteLoading());
    return await DioHelper.postData(path: 'notes/insert', data: {
      'Text': text,
      'UserId': userId,
      'PlaceDateTime':
          DateFormat("yyy-MM-dd'T'hh:mm:ss").format(DateTime.now()).toString(),
    }).then((value) {
      emit(AddNotesSuccess(message: value.data));
    }).catchError((error) {
      emit(AddNotesError());
      print(error.toString());
    });
  }

  ////SQFLITE
  Database? database;
  void createDatabase() {
    openDatabase(
      'notes.db',
      version: 1,
      onCreate: (database, version) {
        // id integer
        // title String
        // date String
        // time String
        // status String

        print('database created');
        database
            .execute('CREATE TABLE notes (note TEXT, date TEXT, userId TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating notes ${error.toString()}');
        });
      },
      onOpen: (database) {
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(CreateSqfLiteSuccess());
    });
  }

  void insertToDatabase({
    required String title,
    required String date,
    required String userId,
  }) async {
    await database!.transaction((txn) {
      return txn
          .rawInsert(
        'INSERT INTO notes(note, date, userId) VALUES("$title", "$date", "$userId")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(InsertToSqfLiteSuccess());
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }
}
