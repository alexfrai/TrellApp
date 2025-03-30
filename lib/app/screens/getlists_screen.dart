import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/widgets/button_create_list.dart';
import 'package:flutter_trell_app/app/widgets/getonelist_widget.dart';

///affiche toutes les lists
class GetListWidget extends StatefulWidget {
  ///parametres requis
  const GetListWidget({required this.boardId, super.key});
  ///id du board
  final String boardId;
  @override
  GetListWidgetState createState() => GetListWidgetState();
}
/// list state
class GetListWidgetState extends State<GetListWidget> {
  final BoardService _boardService = BoardService();
  List<double> _positions = <double>[];
  List<dynamic> _lists = <dynamic>[];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchBoardData()); // Charger les données initiales
    _startAutoRefresh(); // Démarrer l'auto-rafraîchissement
  }

  // Fonction pour démarrer le timer qui actualise les données toutes les 5 secondes
  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      unawaited(_fetchBoardData()); // Actualiser les données toutes les 5 secondes
    });
  }

  // Arrêter le timer lorsque le widget est détruit
  @override
  void dispose() {
    _timer?.cancel(); // Annuler le timer
    unawaited(_boardService.dispose());
    super.dispose();
  }

  // Fonction pour récupérer les données du tableau
  Future<void> _fetchBoardData() async {
    unawaited(_boardService.fetchBoardData(widget.boardId));
    _boardService.boardStream.listen((Map<String, dynamic> data) async {
      if (mounted && data.containsKey('lists')) {
        final List<double> positions = await computeListPositions(data['lists']);
        setState(() {
          _lists = data['lists'];
          _positions = positions;
        });
      }
    });
  }

  ///positions des list
  Future<List<double>> computeListPositions(List<dynamic> lists) async {
    return compute(_extractAndSortPositions, jsonEncode(lists));
  }

  static List<double> _extractAndSortPositions(String encodedLists) {
    final List<dynamic> lists = jsonDecode(encodedLists);
    final List<double> positions = lists
        .map<double>((dynamic list) => (list['pos'] as num).toDouble())
        .toList();
    positions.sort();
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    if (_lists.isEmpty) {
      return const Center(child: Text('Aucune liste trouvée'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Affichage des listes
            ..._lists.map<Widget>((dynamic list) {
              return SizedBox(
                width: 300,
                child: GetOneListWidget(
                  key: ValueKey<dynamic>(list['id']),
                  list: list,
                  refreshLists: _fetchBoardData, // Rafraîchissement de la liste
                  boardId: widget.boardId,
                  positions: _positions,
                ),
              );
            }),

            // Le bouton pour créer une nouvelle liste
            SizedBox(
              width: 300,
              child: Createlistbutton(
                boardId: widget.boardId,
                refreshLists: _fetchBoardData, // Rafraîchissement après création
              ),
            ),
          ],
        ),
      ),
    );
  }
}
