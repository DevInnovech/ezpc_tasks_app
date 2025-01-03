import 'package:ezpc_tasks_app/features/home/setting/providerset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../theme/constraints.dart';

class Utils {
  String generateReferralCode(String uid) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final rawCode = '$uid$timestamp';
    final hash = rawCode.hashCode.toRadixString(36).toUpperCase();

    // Rellenar con caracteres adicionales si es necesario
    return hash.padRight(8, 'X').substring(0, 8);
  }

  static final _selectedDate = DateTime.now();

  static final _initialTime = TimeOfDay.now();

  static Future<void> logoutFunction(BuildContext context) async {
    try {
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();

      // Navegar a la pantalla de AuthenticationScreen
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/authenticationScreen', (Route<dynamic> route) => false);

      // Mostrar un SnackBar confirmando que el logout fue exitoso
      // ignore: use_build_context_synchronously
      Utils.showSnackBar(context, 'Logout successful');
    } catch (e) {
      // Manejar cualquier error durante el proceso de logout
      print('Error logging out: $e');
      // ignore: use_build_context_synchronously
      Utils.errorSnackBar(context, 'Error logging out: $e');
    }
  }

  String formatPrice(BuildContext context, WidgetRef ref, var price) {
    final currency = ref.read(appSettingsProvider).currencyIcon;

    if (price is double) return '$currency${price.toStringAsFixed(0)}';
    if (price is String) {
      final p = double.tryParse(price) ?? 0;
      return '$currency${p.toStringAsFixed(0)}';
    }
    if (price is int) {
      return '$currency${price.toStringAsFixed(0)}';
    }
    return price.toString();
  }

  static String formatPriceIcon(BuildContext context, var price) {
    // final currency =
    //     context.read<AppSettingCubit>().settingModel!.setting.currencyIcon;
    String currency = '\$';
    if (price is double) return currency + price.toStringAsFixed(1);
    if (price is String) {
      final p = double.tryParse(price) ?? 0.0;
      return currency + p.toStringAsFixed(1);
    }
    return currency + price.toStringAsFixed(1);
  }

  static Future<String?> pickSingleImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image.path;
    }
    return null;
  }

  // static Future<String?> pickSingleImage() async {
  //   FilePickerResult? file = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['jpg', 'jpeg', 'png', 'gif']);
  //   if (file != null) {
  //     File image = File(file.files.single.path!);
  //     return image.path;
  //   } else {
  //     return null;
  //   }
  // }

  // static Future<List<String>> pickMultipleImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final List<String> imageList = [];
  //   final List<XFile?> images = await picker.pickMultiImage();
  //   if (images.isNotEmpty) {
  //     // imageList.addAll(images);
  //     //  return images.map((e) => imageList.add(e!.path)).toList();
  //     for (var i in images) {
  //       imageList.add(i!.path.toString());
  //     }
  //     debugPrint('picked images: ${imageList.length}');
  //     return imageList;
  //   }
  //   return [];
  // }

  static String formatDate(var date) {
    late DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.parse(date);
    } else {
      dateTime = date;
    }

    // return DateFormat.MMMEd().format(_dateTime.toLocal());
    return DateFormat.yMMMMd().format(dateTime.toLocal());
  }

  static String dataAndTimeFormat(String time) {
    final DateTime dateTime = DateTime.parse(time);
    final DateFormat formatter = DateFormat('h:mm a - MMM d, y');
    return formatter.format(dateTime);
  }

  static String scheduleTimeFormat(String input) {
    final DateFormat inputFormat = DateFormat("dd-MM-yyyy");
    final DateFormat outputFormat = DateFormat("dd MMM, y");
    final DateTime dateTime = inputFormat.parse(input);
    return outputFormat.format(dateTime);
  }

  static String timeAgo(var date) {
    late DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.now();
    } else {
      dateTime = date;
    }
    return DateFormat.jm().format(dateTime);
  }

  // static String timeAgo(String? time) {
  //   try {
  //     if (time == null) return '';
  //     return timeago.format(DateTime.parse(time));
  //   } catch (e) {
  //     return '';
  //   }
  // }

  /* static BlocListener<LoginBloc, LoginStateModel> logoutListener() {
    return BlocListener<LoginBloc, LoginStateModel>(
      listener: (context, state) {
        final logout = state.loginState;
        if (logout is LoginStateLogoutLoading) {
          Utils.loadingDialog(context);
        } else {
          Utils.closeDialog(context);
          if (logout is LoginStateLogoutError) {
            Utils.errorSnackBar(context, logout.message);
          } else if (logout is LoginStateLogoutLoaded) {
            Utils.showSnackBar(context, logout.message);
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.authenticationScreen,
              (route) => false,
            );
          }
        }
      },
    );
  }*/

/*  static Future<void> logoutFunction(BuildContext context) async {
    context.read<LoginBloc>().add(const LoginEventLogout());
  }*/

  static withdrawStatus(String code) {
    switch (code) {
      case '0':
        return 'Pending';
      case '1':
        return 'Completed';
      default:
        return '';
    }
  }

  static String getStatusCode(String code) {
    switch (code) {
      case '0':
        return 'Inactive';
      case '1':
        return 'Active';
      default:
        return '';
    }
  }

  static status(int i) {
    switch (i) {
      case 1:
        return 'Active';
      case 2:
        return 'Pending';
      case 3:
        return 'Completed';
      case 4:
        return 'Rejected';
      default:
        return 'No Status';
    }
  }

  static statusTextColor(int i) {
    switch (i) {
      case 1:
        return greenColor;
      case 2:
        return secondaryColor;
      case 3:
        return primaryColor;
      case 4:
        return redColor;
      default:
        return transparent;
    }
  }

  static String orderStatus(String orderStatus) {
    switch (orderStatus) {
      case 'awaiting':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'started':
        return 'Started';
      case 'success':
        return 'Success';
      case 'Paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'active':
        return 'Active';
      case 'approved':
        return 'Active';
      case 'cancelled':
        return 'Cancelled';
      case 'decliened':
        return 'Cancelled';
      case 'in_progress':
        return 'In progress';
      case 'in progress':
        return 'In progress';
      case '0':
        return 'In-active';
      case '1':
        return 'Active';
      default:
        return 'Declined';
    }
  }

  static Color getBgColor(String status) {
    switch (status) {
      case "awaiting":
        return const Color(0xffFEEEEE);
      case "pending":
        return const Color(0xffFEEEEE);
      case "Active":
        return const Color(0xFFB3CAFF).withOpacity(1);
      case "started":
        return const Color(0xFFB3CAFF).withOpacity(1);
      case "active":
        return const Color(0xff00BF8C).withOpacity(0.2);
      case "accepted":
        return const Color(0xff00BF8C).withOpacity(0.2);
      case "approved":
        return const Color(0xff00BF8C).withOpacity(0.2);
      case "success":
        return const Color(0xff00BF8C).withOpacity(0.2);
      case "in progress":
        return const Color(0xff378FFF).withOpacity(0.2);

      case "1":
        return const Color(0xff00BF8C).withOpacity(1);
      case "0":
        return redColor.withOpacity(1);
      case "completed":
        return const Color(0xff378FFF).withOpacity(0.2);
      case "cancelled":
        return Colors.transparent;
      case "Paid":
        return const Color(0xff00BF8C).withOpacity(0.1);
      default:
        return const Color(0xffFEEEEE);
    }
  }

  static Color textColor(String status) {
    switch (status) {
      case "awaiting":
        return redColor;
      case "pending":
        return redColor;
      case "active":
        return greenColor;
      case "accepted":
        return const Color.fromARGB(255, 255, 255, 255);
      case "started":
        return const Color.fromARGB(255, 17, 47, 218);
      case "approved":
        return greenColor;
      case "success":
        return greenColor;
      case "completed":
        return primaryColor;
      case "cancelled":
        return Colors.red;
      case "0":
        return Colors.red;
      case "1":
        return greenColor;
      case "declined":
        return Colors.red;
      case "Paid":
        return greenColor;
      default:
        return primaryColor;
    }
  }

  static String convertToAgo(String? time) {
    Duration diff = DateTime.now().difference(DateTime.parse(time!));

    try {
      if (diff.inDays >= 1) {
        return '${diff.inDays} days ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours} hours ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes} minutes ago';
      } else if (diff.inSeconds >= 1) {
        return '${diff.inSeconds} seconds ago';
      } else {
        return 'Just Now';
      }
    } catch (e) {
      return '';
    }
  }

  static Widget verticalSpace(double size) {
    return SizedBox(height: size.h);
  }

  static Widget horizontalSpace(double size) {
    return SizedBox(width: size.w);
  }

  static double hSize(double size) {
    return size.w;
  }

  static double vSize(double size) {
    return size.h;
  }

  static EdgeInsets symmetric({double h = 20.0, v = 0.0}) {
    return EdgeInsets.symmetric(
        horizontal: Utils.hPadding(size: h), vertical: Utils.vPadding(size: v));
  }

  static double radius(double radius) {
    return radius.sp;
  }

  static BorderRadius borderRadius({double r = 10.0}) {
    return BorderRadius.circular(Utils.radius(r));
  }

  static EdgeInsets all({double value = 0.0}) {
    return EdgeInsets.all(value.dm);
  }

  static EdgeInsets only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
        left: left.w, top: top.h, right: right.w, bottom: bottom.h);
  }

  static double vPadding({double size = 20.0}) {
    return size.h;
  }

  static double hPadding({double size = 20.0}) {
    return size.w;
  }

  static double toDouble(String? number) {
    try {
      if (number == null) return 0;
      return double.tryParse(number) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static double toInt(String? number) {
    try {
      if (number == null) return 0;
      return double.tryParse(number) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<DateTime?> selectDate(BuildContext context) => showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1990, 1),
        lastDate: DateTime(2050),
      );

  static Future<TimeOfDay?> selectTime(BuildContext context) =>
      showTimePicker(context: context, initialTime: _initialTime);

  static void closeKeyBoard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static loadingDialog(
    BuildContext context, {
    bool barrierDismissible = false,
  }) {
    // closeDialog(context);
    showCustomDialog(
      context,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(width: 15),
              Text('Please wait a moment')
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static String convertToSlug(String input) {
    // Replace spaces and special characters with hyphens and lowercase the string
    return input.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\d]+'), '-');
  }

  static bool _isDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;

  static void closeDialog(BuildContext context) {
    if (_isDialogShowing(context)) {
      Navigator.pop(context);
    }
  }

  static Future showCustomDialog(
    BuildContext context, {
    Widget? child,
    bool barrierDismissible = false,
    Color bgColor = whiteColor,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: child,
        );
      },
    );
  }

  static void errorSnackBar(BuildContext context, String errorMsg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(color: Colors.red)),
        ),
      );
  }

  static void showSnackBar(BuildContext context, String msg,
      [Color textColor = whiteColor]) {
    final snackBar = SnackBar(
        duration: const Duration(milliseconds: 800),
        content: Text(msg, style: TextStyle(color: textColor)));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void serviceUnAvailable(BuildContext context, String msg,
      [Color textColor = Colors.white]) {
    final snackBar = SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 500),
        content: Text(msg, style: TextStyle(color: textColor)));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSnackBarWithAction(
      BuildContext context, String msg, VoidCallback onPress,
      [Color textColor = primaryColor]) {
    final snackBar = SnackBar(
      content: Text(msg, style: TextStyle(color: textColor)),
      action: SnackBarAction(
        label: 'Active',
        onPressed: onPress,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class InfoLabel extends StatelessWidget {
  const InfoLabel({
    super.key,
    this.label,
    this.text,
  });
  final String? label;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "${label!} : ",
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400, color: blackColor, fontSize: 14.0),
        children: [
          TextSpan(
            text: text!,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: blackColor, fontSize: 16.0),
          )
        ],
      ),
    );
  }
}
