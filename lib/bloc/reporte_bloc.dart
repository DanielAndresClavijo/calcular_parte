import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/models/resume_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/models/seccion_data.dart';

class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  ReporteBloc() : super(ReporteInitial()) {
    on<LoadAppData>(_onLoadAppData);
    on<SaveAppData>(_onSaveAppData);
    on<ClearAppData>(_onClearAppData);
    on<LoadTiposSugeridos>(_onLoadTiposSugeridos);
    on<AddTipoSugerido>(_onAddTipoSugerido);
    on<UpdateTipoSugerido>(_onUpdateTipoSugerido);
    on<RemoveTipoSugerido>(_onRemoveTipoSugerido);
    on<AddSeccion>(_onAddSeccion);
    on<RemoveMultipleSecciones>(_onRemoveMultipleSecciones);
    on<UpdateSeccion>(_onUpdateSeccion);
    on<UpdateSeccionName>(_onUpdateSeccionName);
    on<UpdateNovedadDetalle>(_onUpdateNovedadDetalle);
    on<RemoveNovedadDetalle>(_onRemoveNovedadDetalle);
    on<AddNovedadDetalle>(_onAddNovedadDetalle);
    on<UpdateTipoInAllSections>(_onUpdateTipoInAllSections);
  }

  Future<void> _onLoadAppData(
    LoadAppData event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar tipos sugeridos
      final tiposSugeridos = prefs.getStringList('novedad_tipos') ?? [];
      
      // Cargar secciones
      final seccionesJson = prefs.getString('secciones_data');
      List<SeccionData> secciones = [];
      
      if (seccionesJson != null) {
        final List<dynamic> seccionesList = json.decode(seccionesJson);
        secciones = seccionesList.map((json) => SeccionData.fromJson(json)).toList();
      }
      
      // Calcular resumen
      final resumen = _calculateResumen(secciones);
      
      emit(ReporteUpdated(secciones, resumen, tiposSugeridos));
    } catch (e) {
      // En caso de error, mantener el estado inicial
      emit(ReporteUpdated([], ResumeData(), []));
    }
  }

  Future<void> _onSaveAppData(
    SaveAppData event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar secciones
      final seccionesJson = json.encode(
        state.secciones.map((seccion) => seccion.toJson()).toList(),
      );
      await prefs.setString('secciones_data', seccionesJson);
      
      // Guardar tipos sugeridos
      await prefs.setStringList('novedad_tipos', state.tiposSugeridos);
    } catch (e) {
      // En caso de error, no hacer nada
    }
  }

  Future<void> _onLoadTiposSugeridos(
    LoadTiposSugeridos event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tiposSugeridos = prefs.getStringList('novedad_tipos') ?? [];
      emit(ReporteUpdated(state.secciones, state.resumen, tiposSugeridos));
    } catch (e) {
      // En caso de error, mantener el estado actual con lista vacía
      emit(ReporteUpdated(state.secciones, state.resumen, []));
    }
  }

  Future<void> _onAddTipoSugerido(
    AddTipoSugerido event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final newTipos = {...state.tiposSugeridos, event.nuevoTipo};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('novedad_tipos', newTipos.toList());
      emit(ReporteUpdated(state.secciones, state.resumen, newTipos.toList()));
    } catch (e) {
      // En caso de error, mantener el estado actual
    }
  }

  Future<void> _onUpdateTipoSugerido(
    UpdateTipoSugerido event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final newTipos = List<String>.from(state.tiposSugeridos);
      final index = newTipos.indexOf(event.oldTipo);
      if (index != -1) {
        newTipos[index] = event.newTipo;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('novedad_tipos', newTipos);
        emit(ReporteUpdated(state.secciones, state.resumen, newTipos));
      }
    } catch (e) {
      // En caso de error, mantener el estado actual
    }
  }

  Future<void> _onRemoveTipoSugerido(
    RemoveTipoSugerido event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final newTipos = List<String>.from(state.tiposSugeridos);
      newTipos.remove(event.tipo);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('novedad_tipos', newTipos);
      emit(ReporteUpdated(state.secciones, state.resumen, newTipos));
    } catch (e) {
      // En caso de error, mantener el estado actual
    }
  }

  void _onAddSeccion(AddSeccion event, Emitter<ReporteState> emit) {
    final newSeccion = SeccionData(
      name: 'Sección ${state.secciones.length + 1}',
      fe: '',
      fd: '',
      nv: '0',
      det: [NovedadDetalleDefault()],
    );
    final newSecciones = List<SeccionData>.from(state.secciones)
      ..add(newSeccion);

    final resumen = _calculateResumen(newSecciones);
    final newState = ReporteUpdated(newSecciones, resumen, state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de agregar sección
    add(SaveAppData());
  }

  void _onRemoveMultipleSecciones(
    RemoveMultipleSecciones event,
    Emitter<ReporteState> emit,
  ) {
    final newSecciones = List<SeccionData>.from(state.secciones);
    final indicesToRemove = event.indices..sort((a, b) => b.compareTo(a));
    for (final index in indicesToRemove) {
      newSecciones.removeAt(index);
    }

    final resumen = _calculateResumen(newSecciones);
    final newState = ReporteUpdated(newSecciones, resumen, state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de eliminar secciones
    add(SaveAppData());
  }

  void _onUpdateSeccion(UpdateSeccion event, Emitter<ReporteState> emit) {
    final newSecciones = List<SeccionData>.from(state.secciones);
    final seccionToUpdate = newSecciones[event.index];

    final feStr = event.fe ?? seccionToUpdate.fe;
    final fdStr = event.fd ?? seccionToUpdate.fd;

    final fe = int.tryParse(feStr) ?? 0;
    final fd = int.tryParse(fdStr) ?? 0;
    String nv;
    List<NovedadDetalle> newDet;

    if (feStr.isNotEmpty && fdStr.isNotEmpty) {
      if (fe < fd) {
        nv = '!'; // Error state
        newDet = seccionToUpdate.det
            .map((d) => d.copyWith(cantidad: 0))
            .toList();
      } else {
        final nvInt = fe - fd;
        nv = nvInt.toString();
        newDet = _distributeNovedades(nvInt, seccionToUpdate.det);
      }
    } else {
      // Mantener el valor anterior si los campos están vacíos
      nv = seccionToUpdate.nv;
      newDet = seccionToUpdate.det;
    }

    final updatedSeccion = seccionToUpdate.copyWith(
      fe: feStr,
      fd: fdStr,
      nv: nv,
      det: newDet,
    );

    newSecciones[event.index] = updatedSeccion;

    final newState = ReporteUpdated(newSecciones, _calculateResumen(newSecciones), state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de actualizar sección
    add(SaveAppData());
  }

  void _onUpdateSeccionName(
    UpdateSeccionName event,
    Emitter<ReporteState> emit,
  ) {
    final newSecciones = List<SeccionData>.from(state.secciones);
    final seccionToUpdate = newSecciones[event.index];

    final updatedSeccion = seccionToUpdate.copyWith(name: event.newName);

    newSecciones[event.index] = updatedSeccion;

    final resumen = _calculateResumen(newSecciones);
    final newState = ReporteUpdated(newSecciones, resumen, state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de actualizar nombre
    add(SaveAppData());
  }

  void _onUpdateNovedadDetalle(
    UpdateNovedadDetalle event,
    Emitter<ReporteState> emit,
  ) {
    // Validaciones iniciales
    if (event.seccionIndex < 0 || event.seccionIndex >= state.secciones.length) {
      return;
    }

    final newSecciones = List<SeccionData>.from(state.secciones);
    final seccionToUpdate = newSecciones[event.seccionIndex];
    
    if (event.detalleIndex < 0 || event.detalleIndex >= seccionToUpdate.det.length) {
      return;
    }

    final totalNv = int.tryParse(seccionToUpdate.nv) ?? 0;
    List<NovedadDetalle> updatedDetList = List<NovedadDetalle>.from(seccionToUpdate.det);

    // Validar que el nuevo tipo no esté duplicado (excluyendo el detalle actual)
    final existingTypes = updatedDetList
        .asMap()
        .entries
        .where((entry) => entry.key != event.detalleIndex)
        .map((entry) => entry.value.tipo.toLowerCase().trim())
        .toSet();

    final newTipo = event.newsDetalle.tipo.toLowerCase().trim();
    if (existingTypes.contains(newTipo)) {
      return; // Prevenir duplicados
    }

    // Actualiza el detalle modificado
    updatedDetList[event.detalleIndex] = event.newsDetalle;

    // Ajustar el detalle NovedadDetalleDefault para mantener la suma total
    _ajustarNovedadDetalleDefault(updatedDetList, totalNv);

    final updatedSeccion = seccionToUpdate.copyWith(det: updatedDetList);
    newSecciones[event.seccionIndex] = updatedSeccion;

    final resumen = _calculateResumen(newSecciones);
    final newState = ReporteUpdated(newSecciones, resumen, state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de eliminar novedad detalle
    add(SaveAppData());
  }

  void _onRemoveNovedadDetalle(
    RemoveNovedadDetalle event,
    Emitter<ReporteState> emit,
  ) {
    // Validaciones iniciales
    if (event.seccionIndex < 0 || event.seccionIndex >= state.secciones.length) {
      return;
    }

    final newSecciones = List<SeccionData>.from(state.secciones);
    final seccionToUpdate = newSecciones[event.seccionIndex];
    
    if (event.detalleIndex < 0 || event.detalleIndex >= seccionToUpdate.det.length) {
      return;
    }

    final updatedDetList = List<NovedadDetalle>.from(seccionToUpdate.det);
    final detalleAEliminar = updatedDetList[event.detalleIndex];

    // No permitir eliminar el detalle por defecto si es el único
    if (detalleAEliminar.tipo == NovedadDetalleDefault.tipoDefault && 
        updatedDetList.length == 1) {
      return;
    }

    final removedCantidad = detalleAEliminar.cantidad;
    updatedDetList.removeAt(event.detalleIndex);

    // Si el detalle eliminado tenía una cantidad, se suma al de NovedadDetalleDefault
    if (removedCantidad > 0) {
      _agregarCantidadADetalleDefault(updatedDetList, removedCantidad);
    }

    final updatedSeccion = seccionToUpdate.copyWith(det: updatedDetList);
    newSecciones[event.seccionIndex] = updatedSeccion;

    final resumen = _calculateResumen(newSecciones);
    final newState = ReporteUpdated(newSecciones, resumen, state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de agregar novedad detalle
    add(SaveAppData());
  }

  void _onAddNovedadDetalle(
    AddNovedadDetalle event,
    Emitter<ReporteState> emit,
  ) {
    // Validaciones iniciales
    if (event.seccionIndex < 0 || event.seccionIndex >= state.secciones.length) {
      return;
    }

    final newSecciones = List<SeccionData>.from(state.secciones);
    final seccionToUpdate = newSecciones[event.seccionIndex];
    final newDetList = List<NovedadDetalle>.from(seccionToUpdate.det);

    // Validar que el tipo no exista (case-insensitive)
    final tipoExistente = newDetList.any(
      (d) => d.tipo.toLowerCase().trim() == event.nuevoDetalle.tipo.toLowerCase().trim(),
    );
    
    if (tipoExistente) {
      return;
    }

    // Verificar si hay suficiente cantidad disponible
    if (!_hayCantidadDisponible(newDetList, event.nuevoDetalle.cantidad)) {
      return;
    }

    // Reducir la cantidad del detalle por defecto si es necesario
    _reducirCantidadDeDetalleDefault(newDetList, event.nuevoDetalle.cantidad);

    newDetList.add(event.nuevoDetalle);

    final updatedSeccion = seccionToUpdate.copyWith(det: newDetList);
    newSecciones[event.seccionIndex] = updatedSeccion;

    final resumen = _calculateResumen(newSecciones);
    final newState = ReporteUpdated(newSecciones, resumen, state.tiposSugeridos);
    emit(newState);
    
    // Guardar automáticamente después de actualizar tipo en todas las secciones
    add(SaveAppData());
  }

  // Métodos auxiliares para mejorar la legibilidad y reutilización
  void _ajustarNovedadDetalleDefault(List<NovedadDetalle> detalles, int totalNv) {
    final detalleDefault = const NovedadDetalleDefault();
    final sinDefinirIndex = detalles.indexWhere(
      (d) => d.tipo == detalleDefault.tipo,
    );

    // Calcular la suma de todos los detalles excepto el por defecto
    final otrosDetallesSuma = detalles
        .where((d) => d.tipo != detalleDefault.tipo)
        .fold<int>(0, (sum, d) => sum + d.cantidad);

    final cantidadSinDefinir = totalNv - otrosDetallesSuma;

    if (sinDefinirIndex != -1) {
      if (cantidadSinDefinir <= 0) {
        // Si no hay cantidad restante, eliminar el detalle por defecto
        detalles.removeAt(sinDefinirIndex);
      } else {
        // Actualizar la cantidad del detalle por defecto
        detalles[sinDefinirIndex] = detalles[sinDefinirIndex].copyWith(
          cantidad: cantidadSinDefinir,
        );
        // Mover el detalle por defecto al inicio si no está ahí
        _moverDetalleDefaultAlInicio(detalles);
      }
    } else if (cantidadSinDefinir > 0) {
      // Agregar detalle por defecto al inicio si hay cantidad restante
      detalles.insert(0, detalleDefault.copyWith(cantidad: cantidadSinDefinir));
    }
  }

  void _agregarCantidadADetalleDefault(List<NovedadDetalle> detalles, int cantidad) {
    final detalleDefault = const NovedadDetalleDefault();
    final sinDefinirIndex = detalles.indexWhere(
      (d) => d.tipo == detalleDefault.tipo,
    );

    if (sinDefinirIndex != -1) {
      final sinDefinirDetalle = detalles[sinDefinirIndex];
      detalles[sinDefinirIndex] = sinDefinirDetalle.copyWith(
        cantidad: sinDefinirDetalle.cantidad + cantidad,
      );
      // Mover el detalle por defecto al inicio si no está ahí
      _moverDetalleDefaultAlInicio(detalles);
    } else {
      // Si no existe NovedadDetalleDefault, se agrega uno nuevo al inicio
      detalles.insert(0, detalleDefault.copyWith(cantidad: cantidad));
    }
  }

  bool _hayCantidadDisponible(List<NovedadDetalle> detalles, int cantidadNecesaria) {
    if (cantidadNecesaria <= 0) return true;

    final detalleDefault = const NovedadDetalleDefault();
    final sinDefinirIndex = detalles.indexWhere(
      (d) => d.tipo == detalleDefault.tipo,
    );

    if (sinDefinirIndex == -1) return false;

    return detalles[sinDefinirIndex].cantidad >= cantidadNecesaria;
  }

  void _reducirCantidadDeDetalleDefault(List<NovedadDetalle> detalles, int cantidadAReducir) {
    if (cantidadAReducir <= 0) return;

    final detalleDefault = const NovedadDetalleDefault();
    final sinDefinirIndex = detalles.indexWhere(
      (d) => d.tipo == detalleDefault.tipo,
    );

    if (sinDefinirIndex == -1) return;

    final sinDefinir = detalles[sinDefinirIndex];
    final cantidadRestante = sinDefinir.cantidad - cantidadAReducir;

    if (cantidadRestante <= 0) {
      // Si la cantidad restante es 0 o menos, eliminamos NovedadDetalleDefault
      detalles.removeAt(sinDefinirIndex);
    } else {
      // Actualizamos NovedadDetalleDefault con la cantidad restante
      detalles[sinDefinirIndex] = sinDefinir.copyWith(cantidad: cantidadRestante);
      // Mover el detalle por defecto al inicio si no está ahí
      _moverDetalleDefaultAlInicio(detalles);
    }
  }

  void _moverDetalleDefaultAlInicio(List<NovedadDetalle> detalles) {
    final detalleDefault = const NovedadDetalleDefault();
    final sinDefinirIndex = detalles.indexWhere(
      (d) => d.tipo == detalleDefault.tipo,
    );

    // Si el detalle por defecto no está en la primera posición, moverlo
    if (sinDefinirIndex > 0) {
      final detalleAMover = detalles.removeAt(sinDefinirIndex);
      detalles.insert(0, detalleAMover);
    }
  }

  ResumeData _calculateResumen(List<SeccionData> secciones) {
    if (secciones.isEmpty) return ResumeData();

    final totalFe = secciones.fold<int>(
      0,
      (sum, seccion) => sum + (int.tryParse(seccion.fe) ?? 0),
    );
    final totalFd = secciones.fold<int>(
      0,
      (sum, seccion) => sum + (int.tryParse(seccion.fd) ?? 0),
    );
    final totalNv = secciones.fold<int>(0, (sum, seccion) {
      final nvInt = int.tryParse(seccion.nv);
      return sum + (nvInt ?? 0);
    });
    return ResumeData(
      fe: totalFe.toString(),
      fd: totalFd.toString(),
      nv: totalNv.toString(),
    );
  }

  List<NovedadDetalle> _distributeNovedades(
    int totalNv,
    List<NovedadDetalle> detalles,
  ) {
    final List<NovedadDetalle> newDetalles = List.from(
      detalles.map((d) => d.copyWith()),
    );

    final defaultDetalle = const NovedadDetalleDefault();
    final sinDefinirIndex = newDetalles.indexWhere(
      (d) => d.tipo == defaultDetalle.tipo,
    );

    if (sinDefinirIndex == -1) {
      newDetalles.insert(0, defaultDetalle);
    }

    final otherDetallesSuma = newDetalles
        .where((d) => d.tipo != defaultDetalle.tipo)
        .fold<int>(0, (sum, d) => sum + d.cantidad);

    final sinDefinirCantidad = totalNv - otherDetallesSuma;

    final finalSinDefinirIndex = newDetalles.indexWhere(
      (d) => d.tipo == defaultDetalle.tipo,
    );
    newDetalles[finalSinDefinirIndex] = newDetalles[finalSinDefinirIndex]
        .copyWith(cantidad: sinDefinirCantidad >= 0 ? sinDefinirCantidad : 0);

    // Asegurar que el detalle por defecto esté al inicio
    _moverDetalleDefaultAlInicio(newDetalles);

    return newDetalles;
  }

  Map<String, int> _calcularTiposTotales() {
    final Map<String, int> tiposTotales = {};
    
    for (final seccion in state.secciones) {
      for (final detalle in seccion.det) {
        tiposTotales[detalle.tipo] = (tiposTotales[detalle.tipo] ?? 0) + detalle.cantidad;
      }
    }
    
    return tiposTotales;
  }

  String getResumenText() {
    String resumenText = '📝 RESUMEN POR SECCIÓN\n\n';
    for (int i = 0; i < state.secciones.length; i++) {
      resumenText += state.secciones[i].getCopyText(i);
    }
    resumenText += '\n📝 RESUMEN TOTAL:\n\n';
    resumenText += state.resumen.getCopyText();
    
    // Agregar totales por tipo
    final tiposTotales = _calcularTiposTotales();
    if (tiposTotales.isNotEmpty) {
      resumenText += '\n\n📊 TOTALES POR TIPO NV:\n\n';
      
      // Ordenar tipos: tipo por defecto primero, luego por cantidad descendente
      final sortedTipos = tiposTotales.entries.toList()
        ..sort((a, b) {
          if (a.key == NovedadDetalleDefault.tipoDefault) return -1;
          if (b.key == NovedadDetalleDefault.tipoDefault) return 1;
          return b.value.compareTo(a.value);
        });
      
      for (final entry in sortedTipos) {
        final isDefaultType = entry.key == NovedadDetalleDefault.tipoDefault;
        final icon = isDefaultType ? '⚪' : '🔵';
        resumenText += '$icon ${entry.key}: ${entry.value}\n';
      }
    }

    return resumenText;
  }

  void _onUpdateTipoInAllSections(
    UpdateTipoInAllSections event,
    Emitter<ReporteState> emit,
  ) {
    final newSecciones = List<SeccionData>.from(state.secciones);
    
    for (int i = 0; i < newSecciones.length; i++) {
      final seccion = newSecciones[i];
      final updatedDet = seccion.det.map((detalle) {
        if (detalle.tipo == event.oldTipo) {
          return detalle.copyWith(tipo: event.newTipo);
        }
        return detalle;
      }).toList();
      
      newSecciones[i] = seccion.copyWith(det: updatedDet);
    }

    final resumen = _calculateResumen(newSecciones);
    emit(ReporteUpdated(newSecciones, resumen, state.tiposSugeridos));
  }

  Future<void> _onClearAppData(
    ClearAppData event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Limpiar todos los datos
      await prefs.remove('secciones_data');
      await prefs.remove('novedad_tipos');
      
      // Emitir estado inicial
      emit(ReporteUpdated([], ResumeData(), []));
    } catch (e) {
      // En caso de error, mantener el estado actual
    }
  }
}
