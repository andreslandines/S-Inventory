class UserModels {
  final String? id_usuario;
  final String? nombre;
  final String? email;
  final String? contrasena;
  final String rol;

  UserModels({
    this.id_usuario,
    required this.nombre,
    required this.email,
    required this.contrasena,
    this.rol = 'usuario',

  });

  factory UserModels.fromJson(Map<String, dynamic> json) {
    return UserModels(
      id_usuario: json['id_usuario']?.toString(),
      nombre: json['nombre']?? '',
      email: json['email']?? '',
      contrasena: json['contrasena']?? '',
      rol: json['rol'] ?? 'usuario',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre':nombre,
      'email':email,
      'contrasena':contrasena,
      'rol':rol,
    };
  }
}