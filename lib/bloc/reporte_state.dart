import 'package:carabineros/models/resume_data.dart';
import 'package:carabineros/models/seccion_data.dart';
import 'package:equatable/equatable.dart';

abstract class ReporteState extends Equatable {
  final List<SeccionData> secciones;
  final ResumeData resumen;

  const ReporteState(this.secciones, this.resumen);

  @override
  List<Object> get props => [secciones, resumen];
}

class ReporteInitial extends ReporteState {
  ReporteInitial() : super([], ResumeData());
}

class ReporteUpdated extends ReporteState {
  const ReporteUpdated(super.secciones, super.resumen);
}

