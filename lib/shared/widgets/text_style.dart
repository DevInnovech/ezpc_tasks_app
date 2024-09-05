import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class KTextStyle {
  static sourceOpenPro(
          {required double fs, required Color c, required FontWeight fw}) =>
      GoogleFonts.sourceSans3(fontWeight: fw, fontSize: fs.sp, color: c);

  static workSans(
          {required double fs, required Color c, required FontWeight fw}) =>
      GoogleFonts.workSans(fontWeight: fw, fontSize: fs.sp, color: c);
}
