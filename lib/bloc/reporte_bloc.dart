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
  }

  void _onAddSeccion(AddSeccion event, Emitter<ReporteState> emit) {
    final newSeccion = SeccionData(
      name: 'Sección ${state.secciones.length + 1}',
    );
    final newSecciones = List<SeccionData>.from(state.secciones)
      ..add(newSeccion);

    final resumen = _calculateResumen(newSecciones);
    emit(ReporteUpdated(newSecciones, resumen));
  }

  void _onRemoveMultipleSecciones(RemoveMultipleSecciones event, Emitter<ReporteState> emit) {
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

    final updatedSeccion = seccionToUpdate.copyWith(
      fe: event.fe,
      fd: event.fd,
      det: event.det,
    );

    final fe = int.tryParse(updatedSeccion.fe) ?? 0;
    final fd = int.tryParse(updatedSeccion.fd) ?? 0;
    String nv;

    if (updatedSeccion.fe.isNotEmpty && updatedSeccion.fd.isNotEmpty) {
      if (fe < fd) {
        nv = "!";
      } else {
        nv = (fe - fd).toString();
      }
    } else {
      nv = "";
    }

    newSecciones[event.index] = updatedSeccion.copyWith(nv: nv);

    final resumen = _calculateResumen(newSecciones);
    emit(ReporteUpdated(newSecciones, resumen));
  }

  void _onUpdateSeccionName(UpdateSeccionName event, Emitter<ReporteState> emit) {
    final newSecciones = List<SeccionData>.from(state.secciones);
    final seccionToUpdate = newSecciones[event.index];

    final updatedSeccion = seccionToUpdate.copyWith(name: event.newName);

    newSecciones[event.index] = updatedSeccion;

    final resumen = _calculateResumen(newSecciones);
    emit(ReporteUpdated(newSecciones, resumen));
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
    final totalNv = secciones.fold<int>(
      0,
      (sum, seccion) => sum + (int.tryParse(seccion.nv) ?? 0),
    );
    final resumen = ResumeData(
      fe: totalFe.toString(),
      fd: totalFd.toString(),
      nv: totalNv.toString(),
    );
    return resumen;
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
