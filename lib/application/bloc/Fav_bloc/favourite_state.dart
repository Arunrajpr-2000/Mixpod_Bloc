part of 'favourite_bloc.dart';

abstract class FavouriteState extends Equatable {
  const FavouriteState();
}

class FavDelete extends FavouriteState {
  final List<dynamic>? list;

  FavDelete({required this.list});

  @override
  List<Object?> get props => [list];
}

class FavDEleteSecnd extends FavouriteState {
  @override
  List<Object?> get props => [];
}
