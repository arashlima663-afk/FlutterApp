abstract class NetworkInfoEvent {}

class NetworkInfoChanged extends NetworkInfoEvent {
  final String status;
  NetworkInfoChanged(this.status);
}

class NetworkInfoCheckRequested extends NetworkInfoEvent {}
