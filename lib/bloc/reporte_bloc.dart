
import 'package:carabineros/models/resume_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carabineros/bloc/reporte_event.dart';
import 'package:carabineros/bloc/reporte_state.dart';
import 'package:carabineros/models/seccion_data.dart';

class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  ReporteBloc() : super(ReporteInitial()) {
    on<AddSeccion>(_onAddSeccion);
    on<RemoveSeccion>(_onRemoveSeccion);
    on<UpdateSeccion>(_onUpdateSeccion);
    on<ClearAll>(_onClearAll);
  }

  void _onAddSeccion(AddSeccion event, Emitter<ReporteState> emit) {
    final newSecciones = List<SeccionData>.from(state.secciones)
      ..add(const SeccionData());
    emit(ReporteUpdated(newSecciones, state.resumen));
  }

  void _onRemoveSeccion(RemoveSeccion event, Emitter<ReporteState> emit) {
    if (state.secciones.length > 1) {
      final newSecciones = List<SeccionData>.from(state.secciones)
        ..removeAt(event.index);
      emit(ReporteUpdated(newSecciones, state.resumen));
    }
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

  void _onClearAll(ClearAll event, Emitter<ReporteState> emit) {
    emit(ReporteInitial());
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
