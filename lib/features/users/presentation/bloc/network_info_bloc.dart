import 'dart:async';

import 'package:flutter_application_3/features/users/domain/repository/user_repository.dart';
import 'package:flutter_application_3/features/users/presentation/bloc/network_info_event.dart';
import 'package:flutter_application_3/features/users/presentation/bloc/network_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  final NetworkInfoRepository networkInfoRepository;
  late final StreamSubscription<String> _sub;

  NetworkInfoBloc({required this.networkInfoRepository})
    : super(NetworkInfoState.initial()) {
    // Subscribe to the repository stream
    _sub = networkInfoRepository.isConnected().listen((status) {
      add(NetworkInfoChanged(status)); // Dispatch an event safely
    });

    // Handle the NetworkInfoChanged event
    on<NetworkInfoChanged>(_onNetworkInfoChanged);
  }

  // Event handler
  void _onNetworkInfoChanged(
    NetworkInfoChanged event,
    Emitter<NetworkInfoState> emit,
  ) {
    try {
      if (event.status == 'true') {
        emit(state.copyWith(status: NetworkInfoStatus.yes));
      } else if (event.status == 'false') {
        emit(state.copyWith(status: NetworkInfoStatus.no));
      } else if (event.status == 'slow') {
        emit(state.copyWith(status: NetworkInfoStatus.slow));
      }
    } catch (e) {
      emit(state.copyWith(status: NetworkInfoStatus.error, errorMessage: '$e'));
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
