import 'package:equatable/equatable.dart';

import 'package:calcular_parte/models/novedad_detalle.dart';

abstract class ReporteEvent extends Equatable {
  const ReporteEvent();

  @override
  List<Object?> get props => [];
}

class AddSeccion extends ReporteEvent {}


class RemoveMultipleSecciones extends ReporteEvent {
  final List<int> indices;

  const RemoveMultipleSecciones(this.indices);

  @override
  List<Object> get props => [indices];
}

class UpdateSeccion extends ReporteEvent {
  final int index;
  final String? fe;
  final String? fd;
  final List<NovedadDetalle> det;

  const UpdateSeccion(this.index, {this.fe, this.fd, this.det = const []});

  @override
  List<Object?> get props => [index, fe, fd, det];
}

class UpdateSeccionName extends ReporteEvent {
  final int index;
  final String newName;

  const UpdateSeccionName(this.index, this.newName);

  @override
  List<Object> get props => [index, newName];
}

class UpdateNovedadDetalle extends ReporteEvent {
  final int seccionIndex;
  final int detalleIndex;
  final NovedadDetalle newsDetalle;

  const UpdateNovedadDetalle(
      this.seccionIndex, this.detalleIndex, this.newsDetalle);

  @override
  List<Object> get props => [seccionIndex, detalleIndex, newsDetalle];
}

class AddNovedadDetalle extends ReporteEvent {
  final int seccionIndex;
  final NovedadDetalle nuevoDetalle;

  const AddNovedadDetalle(this.seccionIndex, this.nuevoDetalle);

  @override
  List<Object> get props => [seccionIndex, nuevoDetalle];
}

class RemoveNovedadDetalle extends ReporteEvent {
  final int seccionIndex;
  final int detalleIndex;

  const RemoveNovedadDetalle(this.seccionIndex, this.detalleIndex);

  @override
  List<Object> get props => [seccionIndex, detalleIndex];
}

class UpdateTipoInAllSections extends ReporteEvent {
  final String oldTipo;
  final String newTipo;

  const UpdateTipoInAllSections(this.oldTipo, this.newTipo);

  @override
  List<Object> get props => [oldTipo, newTipo];
}
