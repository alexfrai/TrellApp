import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

class MoveListWidget extends StatefulWidget {
  final String listId;
  final List<double> positions;
  final VoidCallback onMoveSuccess;
  final VoidCallback onCancel;

  const MoveListWidget({
    required this.listId,
    required this.positions,
    required this.onMoveSuccess,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  _MoveListWidgetState createState() => _MoveListWidgetState();
}

class _MoveListWidgetState extends State<MoveListWidget> {
  int? _selectedIndex;
  bool _loading = false;
  String? _error;
  double? _currentPos;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _fetchListPosition();
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  Future<void> _fetchListPosition() async {
    try {
      final pos = await ListService.getListPos(widget.listId);
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
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 40), // Décalage sous le bouton
          child: Material(
            color: Colors.grey[800],
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200), // Hauteur max
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.positions.length, (index) {
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
    final newPos = _calculateNewPosition(_selectedIndex!);
    try {
      await ListService.updateListPos(widget.listId, newPos.toString());
      widget.onMoveSuccess();
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
    // Calculer la nouvelle position en fonction de la direction du mouvement
    if (_currentPos! > widget.positions[index]) {
      // Mouvement vers le haut
      return widget.positions[index - 1] + (widget.positions[index] - widget.positions[index - 1]) / 2;
    } else {
      // Mouvement vers le bas
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
          color: Colors.grey[850], // Fond gris
          borderRadius: BorderRadius.circular(12), // Bords arrondis
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: Colors.grey[700], // Fond de la liste déroulante
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
              children: [
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
