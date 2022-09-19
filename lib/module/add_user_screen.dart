import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/bloc/Notes/notes_cubit.dart';
import 'package:task/bloc/Notes/notes_states.dart';
import 'package:task/module/note_list_screen.dart';
import 'package:task/shared/Components/components.dart';
import 'package:task/shared/Responsive/responsive.dart';
import 'package:task/shared/Theme/Colors/colors.dart';
import 'package:task/shared/Theme/TextStyles/textstyle.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesCubit, NotesStates>(
      listener: (context, state) {
        if (state is AddUserSuccess) {
          showToast(text: state.message, color: Colors.green);
          NotesCubit.get(context).getAllUsers().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return NoteListScreen();
            }));
          });
        }
      },
      builder: (context, state) {
        NotesCubit cubit = NotesCubit.get(context);
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: myAppBar(context, title: 'Add User', isBack: true),
          body: Padding(
            padding: EdgeInsets.symmetric(
                vertical: rhight(context) / 50,
                horizontal: rwidth(context) / 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    height: rhight(context) / 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                        image: const DecorationImage(
                            image: AssetImage('assets/images/user.png'),
                            fit: BoxFit.fitHeight)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Select Image',
                      style: AppTextStyle.noteTextStyle
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: rhight(context) / 50,
                  ),
                  cubit.interestModel != null
                      ? Form(
                          key: cubit.formKey,
                          child: Column(
                            children: [
                              AddUserFormField(
                                text: 'User Name',
                                errorText: 'User Name must not be empty',
                                controller: cubit.userNameController,
                                keyboard: TextInputType.name,
                              ),
                              SizedBox(
                                height: rhight(context) / 30,
                              ),
                              AddUserFormField(
                                text: 'Password',
                                errorText:
                                    'Password should have alphabet and numbers with minimum length 8 chars',
                                controller: cubit.userPasswordController,
                                keyboard: TextInputType.visiblePassword,
                                isPassword: cubit.isSecure,
                                suffix: IconButton(
                                    onPressed: () {
                                      cubit.changevisibilty();
                                    },
                                    icon: Icon(cubit.isSecure
                                        ? Icons.visibility_off
                                        : Icons.visibility)),
                              ),
                              SizedBox(
                                height: rhight(context) / 30,
                              ),
                              AddUserFormField(
                                  text: 'Email',
                                  errorText: 'Incorrect Email',
                                  controller: cubit.userEmailController,
                                  keyboard: TextInputType.emailAddress),
                              SizedBox(
                                height: rhight(context) / 30,
                              ),
                              DropdownButtonFormField(
                                value: cubit.interestModel![0].id,
                                alignment: Alignment.centerLeft,
                                decoration: InputDecoration(
                                    labelText: 'Interest',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                items: cubit.interestModel!.map((e) {
                                  return DropdownMenuItem(
                                      value: e.id, child: Text(e.text));
                                }).toList(),
                                onChanged: (val) {
                                  cubit.changeSelectedVal(val);
                                },
                                borderRadius: BorderRadius.circular(10),
                                icon: const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  size: 30,
                                ),
                              ),
                              SizedBox(
                                height: rhight(context) / 9,
                              ),
                              SizedBox(
                                width: rwidth(context),
                                child: MaterialButton(
                                  height: rhight(context) / 14,
                                  padding: EdgeInsets.zero,
                                  color: AppColors.mainColor,
                                  elevation: 5,
                                  onPressed: () {
                                    if (cubit.formKey.currentState!
                                        .validate()) {
                                      cubit.addUser(
                                          userName:
                                              cubit.userNameController.text,
                                          password:
                                              cubit.userPasswordController.text,
                                          email: cubit.userEmailController.text,
                                          image: null,
                                          intrestId: cubit.selectedInterest ??
                                              cubit.interestModel![0].id);
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: state is AddUserLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'SAVE',
                                          style: AppTextStyle.title,
                                        ),
                                ),
                              )
                            ],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
