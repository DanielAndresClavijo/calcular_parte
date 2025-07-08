import 'package:calcular_parte/models/resume_data.dart';
import 'package:calcular_parte/models/seccion_data.dart';
import 'package:equatable/equatable.dart';

abstract class ReporteState extends Equatable {
  final List<SeccionData> secciones;
  final ResumeData resumen;
  final List<String> tiposSugeridos;

  const ReporteState(this.secciones, this.resumen, this.tiposSugeridos);

  @override
  List<Object> get props => [secciones, resumen, tiposSugeridos];
}

class ReporteInitial extends ReporteState {
  ReporteInitial() : super([], ResumeData(), []);
}

class ReporteUpdated extends ReporteState {
  const ReporteUpdated(super.secciones, super.resumen, super.tiposSugeridos);
}

class ReporteLoading extends ReporteState {
  const ReporteLoading(super.secciones, super.resumen, super.tiposSugeridos);
}

