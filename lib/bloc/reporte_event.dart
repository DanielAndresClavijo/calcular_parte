import 'package:equatable/equatable.dart';

abstract class ReporteEvent extends Equatable {
  const ReporteEvent();

  @override
  List<Object?> get props => [];
}

class AddSeccion extends ReporteEvent {}

class RemoveSeccion extends ReporteEvent {
  final int index;

  const RemoveSeccion(this.index);

  @override
  List<Object> get props => [index];
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

class ClearAll extends ReporteEvent {}

class ChangeSeccion extends ReporteEvent {
  final int index;

  const ChangeSeccion(this.index);

  @override
  List<Object?> get props => [index];
}
