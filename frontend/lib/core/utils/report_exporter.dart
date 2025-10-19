import 'dart:typed_data';

import 'report_exporter_stub.dart'
    if (dart.library.html) 'report_exporter_web.dart'
    if (dart.library.io) 'report_exporter_io.dart';

Future<String?> saveReportFile(Uint8List bytes, String extension) =>
    saveReportFileImpl(bytes, extension);
