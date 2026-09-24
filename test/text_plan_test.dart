import 'package:flutter_test/flutter_test.dart';
import 'package:AcademiaApp/services/plan_share.dart';
import 'package:AcademiaApp/services/text_plan.dart';

void main() {
  test('texto de ficha vira plano', () {
    const sample = 'Treino A - Peito\nSupino reto 4x8-12 descanso 60s\n2. Crucifixo 3 x 12\nTreino B\nAgachamento livre 4 s\u00e9ries de 10\n';
    final routines = parsePlan(encodePlan(textToPlan(sample)!));
    expect(routines.length, 2);
    expect(routines.first.items.first.sets, 4);
    expect(routines.first.items.first.reps, 8);
    expect(routines.first.items.first.restSec, 60);
    expect(routines.last.items.first.name, 'Agachamento livre');
  });
}