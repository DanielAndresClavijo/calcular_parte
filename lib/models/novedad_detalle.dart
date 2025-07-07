import 'package:equatable/equatable.dart';

class NovedadDetalle extends Equatable {
  final String tipo;
  final int cantidad;
  final String? emoji;

  const NovedadDetalle({
    required this.tipo,
    required this.cantidad,
    this.emoji,
  });

  NovedadDetalle copyWith({
    String? tipo,
    int? cantidad,
    String? emoji,
  }) {
    return NovedadDetalle(
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  List<Object?> get props => [tipo, cantidad, emoji];

  factory NovedadDetalle.fromJson(Map<String, dynamic> json) {
    return NovedadDetalle(
      tipo: json['tipo'],
      cantidad: json['cantidad'],
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'emoji': emoji,
    };
  }
}


class NovedadDetalleDefault extends NovedadDetalle {
  const NovedadDetalleDefault()
      : super(
          tipo: 'Desconocido',
          cantidad: 0,
        );

  static String get tipoDefault => const NovedadDetalleDefault().tipo;
  static int get cantidadDefault => const NovedadDetalleDefault().cantidad;
  static String? get emojiDefault => const NovedadDetalleDefault().emoji;
}