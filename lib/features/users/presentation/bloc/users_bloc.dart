import 'package:flutter_application_3/features/users/domain/repository/user_repository.dart';
import 'package:flutter_application_3/features/users/presentation/bloc/users_event.dart';
import 'package:flutter_application_3/features/users/presentation/bloc/users_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository usersRepository;

  UsersBloc({required this.usersRepository}) : super(UsersState.initial()) {
    on<GetUsersEvent>(onGetUsersEvent);
  }

  Future onGetUsersEvent(GetUsersEvent event, Emitter emit) async {
    emit(state.copyWith(status: UsersStatus.loading));
    try {
      var result = await usersRepository.getUsers();
      emit(state.copyWith(status: UsersStatus.success, users: result));
    } catch (e) {
      emit(
        state.copyWith(status: UsersStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
