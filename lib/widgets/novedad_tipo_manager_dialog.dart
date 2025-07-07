import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovedadTipoManagerDialog extends StatefulWidget {
  final Function(String) onTipoGuardado;

  const NovedadTipoManagerDialog({super.key, required this.onTipoGuardado});

  @override
  State<NovedadTipoManagerDialog> createState() =>
      _NovedadTipoManagerDialogState();
}

class _NovedadTipoManagerDialogState extends State<NovedadTipoManagerDialog> {
  List<String> _tipos = [];
  final _newTipoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTipos();
  }

  Future<void> _loadTipos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tipos = prefs.getStringList('novedad_tipos') ?? [];
    });
  }

  Future<void> _saveTipos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('novedad_tipos', _tipos);
  }

  void _addTipo() {
    if (_newTipoController.text.isNotEmpty) {
      setState(() {
        _tipos.add(_newTipoController.text);
        _newTipoController.clear();
      });
      _saveTipos();
    }
  }

  void _removeTipo(int index) {
    setState(() {
      _tipos.removeAt(index);
    });
    _saveTipos();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestionar Tipos de Novedad'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newTipoController,
              decoration: InputDecoration(
                labelText: 'Nuevo Tipo',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTipo,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _tipos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tipos[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTipo(index),
                    ),
                    onTap: () {
                      widget.onTipoGuardado(_tipos[index]);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
