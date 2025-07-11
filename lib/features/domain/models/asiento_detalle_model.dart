class PlanoDetalle {
  final int idPlano;
  final String nombrePlano;
  final String? idCanvas;
  final String idParent;
  final String? idCustom;
  final bool estado;

  PlanoDetalle({
    required this.idPlano,
    required this.nombrePlano,
    required this.estado,
    this.idCanvas,
    required this.idParent,
    this.idCustom,
  });

  factory PlanoDetalle.fromJson(Map<String, dynamic> json) => PlanoDetalle(
    idPlano: json['id'],
    nombrePlano: json['nombre'],
    estado: json['estado'],
    idCanvas: json['idCanvas'],
    idParent: json['idParent'],
    idCustom: json['idCustom'],
  );
/*
  @override
  Map<String, dynamic> toSerializableMap() => {
    'id_plano': idPlano,
    'nombre': nombrePlano,
    'estado': estado,
    'id_canvas': idCanvas,
    'id_parent': idParent,
    'id_custom': idCustom,
  }..removeWhere((_, v) => v == null);
  */
}