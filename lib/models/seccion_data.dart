import 'package:equatable/equatable.dart';
import 'dart:convert';

import 'package:calcular_parte/models/novedad_detalle.dart';

class SeccionData extends Equatable {
  final String name;
  final String fe;
  final String fd;
  final String nv;
  final List<NovedadDetalle> det;

  const SeccionData({
    this.name = '',
    this.fe = '',
    this.fd = '',
    this.nv = '',
    this.det = const [],
  });

  SeccionData copyWith({
    String? name,
    String? fe,
    String? fd,
    String? nv,
    List<NovedadDetalle>? det,
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
    final detalles = det.map((d) => '  - ${d.emoji ?? ''} ${d.tipo}: ${d.cantidad}').join('\n');
    return '🔹 $name:\n'
        'FE: $fe FD: $fd NV: $nv\n'
        'Detalles:\n$detalles\n';
  }

  factory SeccionData.fromMap(Map<String, dynamic> map) {
    return SeccionData(
      name: map['name'] ?? '',
      fe: map['fe'] ?? '',
      fd: map['fd'] ?? '',
      nv: map['nv'] ?? '',
      det: List<NovedadDetalle>.from(map['det']?.map((x) => NovedadDetalle.fromJson(x)) ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fe': fe,
      'fd': fd,
      'nv': nv,
      'det': det.map((x) => x.toJson()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory SeccionData.fromJson(String source) => SeccionData.fromMap(json.decode(source));
}
