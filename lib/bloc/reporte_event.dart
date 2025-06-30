import 'package:equatable/equatable.dart';

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
  final String? det;

  const UpdateSeccion(this.index, {this.fe, this.fd, this.det});

  @override
  List<Object?> get props => [index, fe, fd, det];
}

class ChangeSeccion extends ReporteEvent {
  final int index;

  const ChangeSeccion(this.index);

  @override
  List<Object?> get props => [index];
}
