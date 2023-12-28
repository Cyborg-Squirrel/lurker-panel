import '../model/lurker_model.dart';

class LurkerGridState {
  LurkerGridState({required this.lurkerList});

  LurkerGridState.empty() : lurkerList = [];

  final List<LurkerModel> lurkerList;
}
