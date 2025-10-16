import 'package:intl/intl.dart';

String formatYmdHms(DateTime dt) =>
    DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

String? bearer(String? token) => token == null ? null : 'Bearer $token';
