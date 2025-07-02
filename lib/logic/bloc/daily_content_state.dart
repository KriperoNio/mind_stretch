import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';

abstract class DailyContentState {}

class DailyContentLoading extends DailyContentState {}

class DailyContentLoaded extends DailyContentState {
  final Riddle riddle;
  final String word;
  final WikiPage article;

  DailyContentLoaded({
    required this.riddle,
    required this.word,
    required this.article,
  });
}

class DailyContentError extends DailyContentState {
  final String message;

  DailyContentError(this.message);
}
