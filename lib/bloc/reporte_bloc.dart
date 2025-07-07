import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/models/resume_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/models/seccion_data.dart';

class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  ReporteBloc() : super(ReporteInitial()) {
    on<AddSeccion>(_onAddSeccion);
    on<RemoveMultipleSecciones>(_onRemoveMultipleSecciones);
    on<UpdateSeccion>(_onUpdateSeccion);
    on<UpdateSeccionName>(_onUpdateSeccionName);
    on<UpdateNovedadDetalle>(_onUpdateNovedadDetalle);
    on<RemoveNovedadDetalle>(_onRemoveNovedadDetalle);
    on<AddNovedadDetalle>(_onAddNovedadDetalle);
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
    emit(ReporteUpdated(newSecciones, resumen));
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
    emit(ReporteUpdated(newSecciones, resumen));
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
      nv = seccionToUpdate
          .nv; // Mantener el valor anterior si los campos están vacíos
      newDet = seccionToUpdate.det;
    }

    final updatedSeccion = seccionToUpdate.copyWith(
      fe: feStr,
      fd: fdStr,
      nv: nv,
      det: newDet,
    );

    newSecciones[event.index] = updatedSeccion;

    emit(ReporteUpdated(newSecciones, _calculateResumen(newSecciones)));
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
    emit(ReporteUpdated(newSecciones, resumen));
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
    emit(ReporteUpdated(newSecciones, resumen));
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
    emit(ReporteUpdated(newSecciones, resumen));
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
    emit(ReporteUpdated(newSecciones, resumen));
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

  String getResumenText() {
    String resumenText = '📝 RESUMEN POR SECCIÓN\n\n';
    for (int i = 0; i < state.secciones.length; i++) {
      resumenText += state.secciones[i].getCopyText(i);
    }
    resumenText += '\n📝 RESUMEN TOTAL:\n\n';
    resumenText += state.resumen.getCopyText();

    return resumenText;
  }
}
