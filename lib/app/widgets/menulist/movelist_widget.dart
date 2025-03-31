import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

///modal list
class MoveListWidget extends StatefulWidget {
  ///parametres
  const MoveListWidget({
    required this.listId,
    required this.positions,
    required this.onMoveSuccess,
    required this.onCancel,
    super.key,
  });
  ///id de la liste
  final String listId;
  ///liste de position
  final List<double> positions;
  ///move
  final VoidCallback onMoveSuccess;
  ///cancel
  final VoidCallback onCancel;

  @override
  MoveListWidgetState createState() => MoveListWidgetState();
}

///move state
class MoveListWidgetState extends State<MoveListWidget> {
  int? _selectedIndex;
  bool _loading = false;
  String? _error;
  double? _currentPos;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    unawaited(_fetchListPosition());
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  Future<void> _fetchListPosition() async {
    try {
      final double pos = await ListService.getListPos(widget.listId);
      setState(() {
        _currentPos = pos;
        _selectedIndex = widget.positions.indexOf(pos);
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement de la position : $e';
      });
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showDropdown();
    } else {
      _hideDropdown();
    }
  }

  void _showDropdown() {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 40),
          child: Material(
            color: Colors.grey[800],
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(widget.positions.length, (int index) {
                    return ListTile(
                      title: Text(
                        'Position ${index + 1}',
                        style: TextStyle(
                          color: index == _selectedIndex ? Colors.green : Colors.white,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        _hideDropdown();
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _moveList() async {
    if (_selectedIndex == null || _currentPos == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final double newPos = _calculateNewPosition(_selectedIndex!);
    try {
      await ListService.updateListPos(widget.listId, newPos.toString());
      widget.onMoveSuccess(); // Appelle la fonction pour rafraîchir les données
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du déplacement de la liste : $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  double _calculateNewPosition(int index) {
    if (widget.positions.isEmpty) return 1;

    if (index == 0) {
      return widget.positions[0] / 2;
    } else if (index == widget.positions.length - 1) {
      return widget.positions.last * 2;
    } else {
      if (_currentPos! > widget.positions[index]) {
        return widget.positions[index - 1] + (widget.positions[index] - widget.positions[index - 1]) / 2;
      } else {
        return widget.positions[index] + (widget.positions[index + 1] - widget.positions[index]) / 2;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Move List',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _selectedIndex == null ? 'Select Position' : 'Position ${_selectedIndex! + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: _loading ? null : _moveList,
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: Text(_loading ? 'Moving...' : 'Move'),
                ),
                TextButton(
                  onPressed: () {
                    _hideDropdown();
                    widget.onCancel();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
