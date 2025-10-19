import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> saveReportFileImpl(Uint8List bytes, String extension) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = 'attendance_report_$timestamp.$extension';

  Directory? dir;
  try {
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dir = await getDownloadsDirectory();
    }
  } catch (_) {
    dir = null;
  }

  dir ??= await getTemporaryDirectory();

  final file = File('${dir.path}/$fileName');
  await file.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);

  await OpenFilex.open(file.path);
  return file.path;
}
