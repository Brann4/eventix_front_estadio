class Evento {
  final String id;
  final String nombre;
  final String artista;
  final String fecha;
  final String lugar;
  final String imagenUrl;
  final String svgPath;

  Evento({
    required this.id,
    required this.nombre,
    required this.artista,
    required this.fecha,
    required this.lugar,
    required this.imagenUrl,
    required this.svgPath,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nombre: json['nombre'],
      artista: json['artista'],
      fecha: json['fecha'],
      lugar: json['lugar'],
      imagenUrl: json['imagenUrl'],
      svgPath: json['svgPath'],
    );
  }
}