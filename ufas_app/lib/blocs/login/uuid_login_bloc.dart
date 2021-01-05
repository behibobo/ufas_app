import 'package:bloc/bloc.dart';
import 'package:ufas_app/blocs/login/uuid_login_event.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../authentication/authentication.dart';
import '../../exceptions/exceptions.dart';
import '../../services/services.dart';

class UuidLoginBloc extends Bloc<UuidLoginEvent, LoginState> {
  final AuthenticationBloc _authenticationBloc;
  final AuthenticationService _authenticationService;

  UuidLoginBloc(AuthenticationBloc authenticationBloc,
      AuthenticationService authenticationService)
      : assert(authenticationBloc != null),
        assert(authenticationService != null),
        _authenticationBloc = authenticationBloc,
        _authenticationService = authenticationService,
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(UuidLoginEvent event) async* {
    if (event is LoginInWithUuidButtonPressed) {
      yield* _mapLoginWithUuidToState(event);
    }
  }

  Stream<LoginState> _mapLoginWithUuidToState(
      LoginInWithUuidButtonPressed event) async* {
    yield LoginLoading();
    try {
      final user = await _authenticationService.signInWithUuid(event.uuid);
      if (user != null) {
        _authenticationBloc.add(UserLoggedIn(user: user));
        yield LoginSuccess();
        yield LoginInitial();
      } else {
        yield LoginFailure(error: 'Something very weird just happened');
      }
    } on AuthenticationException catch (e) {
      yield LoginFailure(error: e.message);
    } catch (err) {
      yield LoginFailure(error: err.message ?? 'An unknown error occured');
    }
  }
}
