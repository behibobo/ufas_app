import 'package:equatable/equatable.dart';

abstract class AnonymousLoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInAnonymouslyPressed extends AnonymousLoginEvent {
  LoginInAnonymouslyPressed();

  @override
  List<Object> get props => [];
}
