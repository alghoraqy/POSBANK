import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/Network/remote/dio_helper.dart';
import 'package:task/bloc/Notes/notes_cubit.dart';
import 'package:task/bloc/Notes/notes_states.dart';
import 'package:task/module/note_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DioHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesCubit()
        ..getAllNotes()
        ..getAllUsers()
        ..getAllInteres()
        ..createDatabase(),
      child: BlocConsumer<NotesCubit, NotesStates>(
        listener: (context, state) {},
        builder: (context, states) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: NoteListScreen(),
          );
        },
      ),
    );
  }
}
