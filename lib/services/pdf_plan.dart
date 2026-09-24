import 'package:file_picker/file_picker.dart';
import 'package:pdfrx/pdfrx.dart';

import 'plan_share.dart';
import 'text_plan.dart';

Future<String?> pickPdfPlanJson() async {
  final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
  final path = picked?.files.single.path;
  if (path == null) return null;
  final doc = await PdfDocument.openFile(path);
  try {
    final buf = StringBuffer();
    for (final page in doc.pages) {
      final text = await page.loadText();
      buf.writeln(text?.fullText ?? '');
    }
    final plan = textToPlan(buf.toString());
    return plan == null ? null : encodePlan(plan);
  } finally {
    doc.dispose();
  }
}