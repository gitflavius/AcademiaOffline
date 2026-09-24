final _setsReps = RegExp(r'(\d{1,2})\s*[x\u00d7]\s*(\d{1,3}(?:\s*[-\u2013a]\s*\d{1,3})?)', caseSensitive: false);
final _seriesDe = RegExp(r'(\d{1,2})\s*s[e\u00e9]ries?\s*(?:de|x)?\s*(\d{1,3}(?:\s*[-\u2013a]\s*\d{1,3})?)', caseSensitive: false);
final _rest = RegExp(r'(?:desc(?:anso)?\.?|rest|interv(?:alo)?\.?)\s*[:\-]?\s*(\d{1,3})\s*(seg|min|s|m)?', caseSensitive: false);
final _header = RegExp(r'^(treino|dia|ficha|workout|day)\s*[a-z0-9]{1,2}\b', caseSensitive: false);
final _weekday = RegExp(r'^(segunda|ter[c\u00e7]a|quarta|quinta|sexta|s[a\u00e1]bado|domingo)\b', caseSensitive: false);

String _clean(String s) => s
    .replaceAll(RegExp(r'^[\s\-\u2013\u2022\u00b7*\d.)]+'), '')
    .replaceAll(RegExp(r'[\s:\-\u2013|,;]+$'), '')
    .trim();

int? _restSec(String line) {
  final m = _rest.firstMatch(line);
  if (m == null) return null;
  final n = int.parse(m.group(1)!);
  return (m.group(2) ?? '').toLowerCase().startsWith('m') ? n * 60 : n;
}

Map<String, Object?>? textToPlan(String raw) {
  final routines = <Map<String, Object?>>[];
  var items = <Map<String, Object?>>[];
  var name = 'Treino';
  String? pending;

  void flush() {
    if (items.isNotEmpty) routines.add({'name': name, 'exercises': items});
    items = <Map<String, Object?>>[];
  }

  for (final rawLine in raw.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (_header.hasMatch(line) || _weekday.hasMatch(line)) {
      flush();
      name = line.replaceAll(RegExp(r'[\s:\-\u2013]+$'), '');
      pending = null;
      continue;
    }
    final m = _setsReps.firstMatch(line) ?? _seriesDe.firstMatch(line);
    if (m == null) {
      if (!line.contains(RegExp(r'\d')) && line.length <= 50) pending = _clean(line);
      continue;
    }
    var ex = _clean(line.substring(0, m.start));
    if (ex.isEmpty) ex = _clean(line.substring(m.end).replaceAll(_rest, ''));
    if (ex.isEmpty) ex = pending ?? '';
    pending = null;
    if (ex.isEmpty) continue;
    final rest = _restSec(line);
    items.add({
      'name': ex,
      'sets': int.parse(m.group(1)!),
      'reps': m.group(2)!.replaceAll(' ', ''),
      'rest': ?rest,
    });
  }
  flush();
  return routines.isEmpty ? null : {'routines': routines};
}