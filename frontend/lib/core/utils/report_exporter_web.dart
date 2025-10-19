import 'dart:typed_data';
import 'dart:html' as html;

Future<String?> saveReportFileImpl(Uint8List bytes, String extension) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = 'attendance_report_$timestamp.$extension';

  final lowerExt = extension.toLowerCase();
  String mimeType;
  if (lowerExt == 'pdf') {
    mimeType = 'application/pdf';
  } else if (lowerExt == 'xlsx') {
    mimeType =
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  } else {
    mimeType = 'application/octet-stream';
  }

  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrl(blob);
  final anchor = html.AnchorElement(href: url)
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return fileName;
}
