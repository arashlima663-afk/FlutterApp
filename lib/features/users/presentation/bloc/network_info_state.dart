enum NetworkInfoStatus { wait, yes, no, slow, error }

class NetworkInfoState {
  final NetworkInfoStatus status;
  final String? errorMessage;
  // final List<UserModel>? users;

  NetworkInfoState._({required this.status, this.errorMessage});

  factory NetworkInfoState.initial() =>
      NetworkInfoState._(status: NetworkInfoStatus.no);

  NetworkInfoState copyWith({NetworkInfoStatus? status, String? errorMessage}) {
    return NetworkInfoState._(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
