import 'package:equatable/equatable.dart';

class SeccionData extends Equatable {
  final String name;
  final String fe;
  final String fd;
  final String nv;
  final String det;

  const SeccionData({
    this.name = '',
    this.fe = '',
    this.fd = '',
    this.nv = '',
    this.det = '',
  });

  SeccionData copyWith({
    String? name,
    String? fe,
    String? fd,
    String? nv,
    String? det,
  }) {
    return SeccionData(
      name: name ?? this.name,
      fe: fe ?? this.fe,
      fd: fd ?? this.fd,
      nv: nv ?? this.nv,
      det: det ?? this.det,
    );
  }

  @override
  List<Object> get props => [name, fe, fd, nv, det];

  String getCopyText(int index) {
    final formattedName = this.name.trim();
    final name = formattedName.isNotEmpty ? formattedName : 'Sección ${index + 1}';
    return '🔹 $name:\n'
        'FE: $fe FD: $fd NV: $nv\n'
        'Detalles: $det\n';
  }
}
