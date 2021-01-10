import 'package:bloc/bloc.dart';
import 'package:ufas_app/blocs/login/anonymous_login_event.dart';
import 'package:ufas_app/blocs/login/uuid_login_event.dart';
import 'package:ufas_app/models/user.dart';
import 'package:ufas_app/services/shared_pref.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../authentication/authentication.dart';
import '../../exceptions/exceptions.dart';
import '../../services/services.dart';

class AnonymousLoginBloc extends Bloc<AnonymousLoginEvent, LoginState> {
  final AuthenticationBloc _authenticationBloc;
  final AuthenticationService _authenticationService;

  AnonymousLoginBloc(AuthenticationBloc authenticationBloc,
      AuthenticationService authenticationService)
      : assert(authenticationBloc != null),
        assert(authenticationService != null),
        _authenticationBloc = authenticationBloc,
        _authenticationService = authenticationService,
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(AnonymousLoginEvent event) async* {
    if (event is LoginInAnonymouslyPressed) {
      yield* _mapLoginWithAnonymouslyToState(event);
    }
  }

  Stream<LoginState> _mapLoginWithAnonymouslyToState(
      LoginInAnonymouslyPressed event) async* {
    yield LoginLoading();
    try {
      final user = User(token: '', email: 'trial', uuid: '', authorized: false);
      await SharedPref.save('user', user);
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
