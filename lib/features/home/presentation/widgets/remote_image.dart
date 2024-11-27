import 'package:firebase_storage/firebase_storage.dart';

class RemoteUrls {
  static const String rootUrl = "https://servingo.minionionbd.com/";

  // Mantén las demás constantes y métodos si los datos aún se obtienen desde el servidor
  static const String baseUrl = "${rootUrl}api/";

  // Ajusta el método imageUrl para obtener las imágenes desde Firebase Storage
  static Future<String> imageUrl(String imagePath) async {
    // Crea una referencia al archivo en Firebase Storage
    final ref = FirebaseStorage.instance.ref().child(imagePath);

    // Obtén la URL pública del archivo en Firebase Storage
    String imageUrl = await ref.getDownloadURL();

    return imageUrl;
  }

  // Resto de los métodos permanecen igual...
  static const String userRegister = '${baseUrl}store-register';
  static const String userLogin = '${baseUrl}store-login';

  static String userDashboard(String token) =>
      '${baseUrl}dashboard?token=$token';

  static String userLogOut(String token) =>
      '${baseUrl}user/logout?token=$token';

  static const String sendForgetPassword = '${baseUrl}send-forget-password';
  static const String resendRegisterCode = '${baseUrl}resend-register-code';

  static String storeResetPassword(String code) =>
      '${baseUrl}store-reset-password/$code';

  static String userVerification(String code) =>
      '${baseUrl}user-verification/$code';

  static String userProfile(String token) =>
      '${baseUrl}user/my-profile?token=$token';

  static String updateProfile(String token) =>
      '${baseUrl}update-profile?token=$token';

  static String changePassword(String token) =>
      '${baseUrl}update-password?token=$token';

  static String countryListUrl(String token) =>
      '${baseUrl}user/address/create?token=$token';

  static String stateByCountryId(String countryId, String token) =>
      '${baseUrl}user/state-by-country/$countryId?token=$token';

  static String citiesByStateId(String stateId, String token) =>
      '${baseUrl}user/city-by-state/$stateId?token=$token';

  static String serviceDetail(String slug) => '${baseUrl}service/$slug';

  static String invoiceUrl(String orderId, String token) =>
      '${baseUrl}get-invoice/$orderId?token=$token';

  static String readyBookingUrl(String slug, String token) =>
      '${baseUrl}ready-to-booking/$slug?token=$token';

  static String getScheduleUrl(String token) =>
      '${baseUrl}get-available-schedule?token=$token';

  static String stripePaymentUrl(String slug, String token) =>
      '$baseUrl$slug?token=$token';

  static String submitReviewUrl(String token) =>
      '${baseUrl}store-service-review?token=$token';

  static const String aboutUs = '${baseUrl}about-us';
  static const String faq = '${baseUrl}faq';
  static const String termsAndConditions = '${baseUrl}terms-and-conditions';
  static const String privacyPolicy = '${baseUrl}privacy-policy';
  static const String contactUs = '${baseUrl}contact-us';
  static const String sendContactMessage = '${baseUrl}send-contact-message';
  static const String allServicesUrl = '${baseUrl}services';

  static String serviceTypeUrl(String slug) =>
      '${baseUrl}services?service_type=$slug';

  static String categoryServicesUrl(String slug) => '${baseUrl}services?$slug';

  static String searchUrl(String slug) => '${baseUrl}services?search=$slug';

  static String payWithPaypalWeb(String token, String params) =>
      "${rootUrl}pay-with-paypal-webview?token=$token&$params&request_from=mobile_app";

  static String payWithFlutterWave(String token, String params) =>
      "${rootUrl}flutterwave-webview?token=$token&$params&request_from=mobile_app";

  static String payWithMollieWeb(String token, String params) =>
      "${rootUrl}pay-with-mollie-webview?token=$token&$params&request_from=mobile_app";

  static String payWithInstaMojoWeb(String token, String params) =>
      "${rootUrl}pay-with-instamojo-webview?token=$token&$params&request_from=mobile_app";

  static String payWithPayStackWeb(String token, String params) =>
      "${rootUrl}paystack-web-view?token=$token&$params&request_from=mobile_app";

  static String payWithRazorpayWeb(String token, String params) =>
      "${rootUrl}razorpay-webview?token=$token&$params&request_from=mobile_app";

  static String razorOrder(String token) =>
      '${rootUrl}razorpay-create-token?token=$token';

  static String createNewTicket(String token) =>
      "${baseUrl}ticket-request?token=$token";

  static String sendTicketMessage(String token) =>
      "${baseUrl}send-ticket-message?token=$token";

  static String singleTicket(String id, String token) =>
      "${baseUrl}show-ticket/$id?token=$token";
}
