class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDatasource usersRemoteDatasource;

  UsersRepositoryImpl({required this.usersRemoteDatasource});

  @override
  Future<List<UserModel>> getUsers() async {
    return await usersRemoteDatasource.getUsers();
  }
}

class NetworkInfoImpl implements NetworkInfoRepository {
  final IsConnectedRemoteDatasource isConnectedRemoteDatasource;

  NetworkInfoImpl({required this.isConnectedRemoteDatasource});

  @override
  Stream<String> isConnected() async* {
    yield* isConnectedRemoteDatasource.isConnected();
  }
}
