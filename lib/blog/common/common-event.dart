
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class  SearchEvent extends Equatable {
   SearchEvent([List props = const []]) : super(props);
}

class SearchInitEvent extends  SearchEvent {
  @override
  String toString() => 'SearchInit';
}

class SearchingEvent extends  SearchEvent {
  final String token;

  SearchingEvent({@required this.token}) : super([token]);

  @override
  String toString() => 'Searching { token: $token }';
}

class SearchDoneEvent extends  SearchEvent {
  @override
  String toString() => 'SearchDone';
}

class SearchDataEvent extends  SearchEvent {
  
  @override
  String toString() => 'SearchData';
}

class SearchErrorEvent extends  SearchEvent {
  @override
  String toString() => 'Search Error';
}
