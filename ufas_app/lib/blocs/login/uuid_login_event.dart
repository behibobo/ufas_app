import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class UuidLoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInWithUuidButtonPressed extends UuidLoginEvent {
  final String uuid;

  LoginInWithUuidButtonPressed({@required this.uuid});

  @override
  List<Object> get props => [uuid];
}
