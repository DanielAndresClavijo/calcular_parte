import 'package:equatable/equatable.dart';

class SeccionData extends Equatable {
  final String fe;
  final String fd;
  final String nv;
  final String det;

  const SeccionData({
    this.fe = '',
    this.fd = '',
    this.nv = '',
    this.det = '',
  });

  SeccionData copyWith({
    String? fe,
    String? fd,
    String? nv,
    String? det,
  }) {
    return SeccionData(
      fe: fe ?? this.fe,
      fd: fd ?? this.fd,
      nv: nv ?? this.nv,
      det: det ?? this.det,
    );
  }

  @override
  List<Object> get props => [fe, fd, nv, det];

  String getCopyText(int index) {
    return '🔹 Sección ${index + 1}:\n'
        'FE: $fe FD: $fd NV: $nv\n'
        'Detalles: $det\n';
  }
}
