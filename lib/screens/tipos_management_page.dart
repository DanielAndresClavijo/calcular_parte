import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';

class TiposManagementPage extends StatefulWidget {
  const TiposManagementPage({super.key});

  @override
  State<TiposManagementPage> createState() => _TiposManagementPageState();
}

class _TiposManagementPageState extends State<TiposManagementPage> {
  List<String> _tipos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTipos();
  }



  Future<void> _loadTipos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tipos = prefs.getStringList('novedad_tipos') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _saveTipos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('novedad_tipos', _tipos);
  }

  void _refreshTipos() {
    setState(() {
      // Forzar rebuild de la lista
    });
  }

  String _formatTipo(String tipo) {
    // Remover caracteres especiales y espacios extra
    final formatted = tipo
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remover caracteres especiales
        .replaceAll(RegExp(r'\s+'), ' ') // Reemplazar múltiples espacios con uno solo
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ')
        .trim();
    return formatted;
  }

  void _showAddTipoDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Tipo'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del tipo',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingrese un nombre.';
              }
              if (_tipos.any((tipo) => tipo.toLowerCase() == value.toLowerCase())) {
                return 'Este tipo ya existe.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final nuevoTipo = _formatTipo(controller.text);
                setState(() {
                  _tipos.add(nuevoTipo);
                });
                _saveTipos();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditTipoDialog(String tipoOriginal) {
    final controller = TextEditingController(text: tipoOriginal);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tipo'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del tipo',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingrese un nombre.';
              }
              if (_tipos.any((tipo) => 
                  tipo.toLowerCase() == value.toLowerCase() && 
                  tipo != tipoOriginal)) {
                return 'Este tipo ya existe.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {              
              if (formKey.currentState!.validate()) {
                final nuevoTipo = _formatTipo(controller.text);
                Navigator.of(context).pop(); // Cerrar diálogo de edición
                _showEditOptionsDialog(tipoOriginal, nuevoTipo);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditOptionsDialog(String tipoOriginal, String nuevoTipo) {
    // Obtener el bloc antes de mostrar el diálogo
    final reporteBloc = context.read<ReporteBloc>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Edición'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cómo deseas aplicar el cambio?'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Aplicar a todas las secciones'),
              subtitle: const Text('Sobrescribir en todas las secciones existentes'),
              onTap: () {
                Navigator.of(context).pop();
                _updateTipoInAllSections(tipoOriginal, nuevoTipo, reporteBloc);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Aplicar desde ahora'),
              subtitle: const Text('Solo para nuevas secciones'),
              onTap: () {
                Navigator.of(context).pop();
                _updateTipoOnly(tipoOriginal, nuevoTipo);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _updateTipoInAllSections(String tipoOriginal, String nuevoTipo, ReporteBloc reporteBloc) {
    // Actualizar en el bloc
    reporteBloc.add(
      UpdateTipoInAllSections(tipoOriginal, nuevoTipo),
    );
    
    // Actualizar en la lista de tipos inmediatamente
    setState(() {
      final index = _tipos.indexOf(tipoOriginal);
      if (index != -1) {
        _tipos[index] = nuevoTipo;
      }
    });
    _saveTipos();
    _refreshTipos();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tipo "$tipoOriginal" actualizado a "$nuevoTipo" en todas las secciones'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateTipoOnly(String tipoOriginal, String nuevoTipo) {
    // Solo actualizar en la lista de tipos sugeridos
    setState(() {
      final index = _tipos.indexOf(tipoOriginal);
      if (index != -1) {
        _tipos[index] = nuevoTipo;
      }
    });
    _saveTipos();
    _refreshTipos();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tipo "$tipoOriginal" actualizado a "$nuevoTipo"'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String tipo) async {
    // Verificar si el tipo está siendo usado en el bloc actual
    final reporteBloc = context.read<ReporteBloc>();
    final state = reporteBloc.state;
    
    bool isUsed = false;
    for (final seccion in state.secciones) {
      for (final detalle in seccion.det) {
        if (detalle.tipo == tipo) {
          isUsed = true;
          break;
        }
      }
      if (isUsed) break;
    }

    if (isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar un tipo que está siendo utilizado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el tipo "$tipo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tipos.remove(tipo);
              });
              _saveTipos();
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tipo "$tipo" eliminado'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('Gestión de Tipos'),
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.black,
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tipos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay tipos creados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega tu primer tipo de novedad',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _tipos.length,
                  itemBuilder: (context, index) {
                    final tipo = _tipos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(tipo),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditTipoDialog(tipo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(tipo),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTipoDialog,
          child: const Icon(Icons.add),
        ),
      );
  }
} 