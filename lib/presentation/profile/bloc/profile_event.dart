import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final bool isProUser;

  const UpdateProfileEvent({
    required this.name,
    required this.email,
    required this.isProUser,
  });

  @override
  List<Object> get props => [name, email, isProUser];
}

class UpdateSubscriptionStatusEvent extends ProfileEvent {
  final bool isSubscribed;

  const UpdateSubscriptionStatusEvent({required this.isSubscribed});

  @override
  List<Object> get props => [isSubscribed];
}

class SignOutEvent extends ProfileEvent {
  const SignOutEvent();

  @override
  List<Object> get props => [];
}
