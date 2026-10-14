String etiquetaFecha(DateTime f) {

  final hoy = DateTime.now();
  final d = DateTime(f.year, f.month, f.day);
  final h = DateTime(hoy.year, hoy.month, hoy.day);
  final diff = h.difference(d).inDays;

  if (diff < 0) return 'Programado';
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  if (diff < 7) return 'Hace $diff días';
  return '${f.day.toString().padLeft(2, '0')}/'
         '${f.month.toString().padLeft(2, '0')}/${f.year}';

}