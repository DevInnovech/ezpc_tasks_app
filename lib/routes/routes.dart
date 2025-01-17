import 'package:ezpc_tasks_app/features/About%20me/presentation/screen/preview_aboutme_screen.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/screen/edit_aboutme_screen.dart';
import 'package:ezpc_tasks_app/features/About%20me/presentation/screen/about_me_screen.dart';
import 'package:ezpc_tasks_app/features/checkr/screens/candidate_screen.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/accountverificationscreen.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/greates_page.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/background_check.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/bank_acount.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/basic_register.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/businees_register.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/cliente_provider_selector.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/employer_register.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/password.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/pay_methos.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/provider_employer_selector.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/regitered_screen.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/verification_page.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/selector_fogottpassword.dart';
import 'package:ezpc_tasks_app/features/auth/presentation/screens/verification.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/tracking/booking_tracking_screen.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/SupportChatScreen.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/AllcategoriesScreen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/client_main_screen%20.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/home_screen.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/main_screen.dart';
import 'package:ezpc_tasks_app/features/leaning/presentations/screnn/video_screen.dart';
import 'package:ezpc_tasks_app/features/my%20employe/presentation/screen/employee_screen.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/booking_details_tasks_details.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/provider_tracking.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/models/bank_account_model.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/models/card_model.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/add_bank_account_screen.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/add_card_screen.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/edit_bank_account_screen.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/edit_card_screen.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/payment_settings_screen.dart';
import 'package:ezpc_tasks_app/features/performance/screen/performance.dart';
import 'package:ezpc_tasks_app/features/performance/screen/review.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/screens/referral_screen.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/booking_step.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/request_services.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/services.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/addnew_services_screen.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/detail_scren.dart';
import 'package:ezpc_tasks_app/features/settings/models/company_models.dart';
import 'package:ezpc_tasks_app/features/settings/presentation/screens/CompanyProfileScreen.dart';
import 'package:ezpc_tasks_app/features/settings/presentation/screens/change_password.dart';
import 'package:ezpc_tasks_app/features/settings/presentation/screens/edit_profile.dart';
import 'package:ezpc_tasks_app/features/settings/presentation/screens/settings_config.dart';
import 'package:ezpc_tasks_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:ezpc_tasks_app/features/splash/splash_main.dart';
import 'package:ezpc_tasks_app/features/splash/splash_screen.dart';
import 'package:ezpc_tasks_app/features/two_factor_auth/presentation/screen/two_factor_setup_screen.dart';
import 'package:ezpc_tasks_app/features/two_factor_auth/presentation/screen/verification_screen.dart';
import 'package:flutter/material.dart';

//ultima union
class RouteNames {
  static const String popularServicesScreen = '/popularServicesScreen';
  static const String splashScreen = '/splashScreen';
  static const String onBoardingScreen = '/onBoardingScreen';
  static const String authenticationScreen = '/authenticationScreen';
//learnig
  static const String learningScreen = '/learning'; // Nueva ruta para Learning
  static const String accountVerificationScreen = '/accountverificationscreen';
  static const String createCandidateScreen = '/createCandidateScreen';

  // static const String signInScreen = '/signInScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String verificationCodeScreen = '/verificationCodeScreen';

  static const String resetOptionSelectionScreen =
      '/ResetOptionSelectionScreen';

  static const String accountTypeSelectionScreen =
      '/accountTypeSelectionScreen';
  /* static const String providerTypeSelectionScreen =
      '/providerTypeSelectionScreen';*/
  static const String providerSelectionEmployer = '/providerSelectionEmployer';

  // static const String registrationScreen = '/registrationScreen';
  static const String createAccountScreen = '/createAccountScreen';
  static const String signUpBusinessAccountScreen =
      '/signUpBusinessAccountScreen';
  static const String clientRegistrationExistingScreen =
      '/clientRegistrationExistingScreen';
  static const String signUpWithBusinessCodeScreen =
      '/signUpWithBusinessCodeScreen';
  static const String passwordAccountpage = '/passwordAccountpage';

  static const String addCardPaymentMethodScreen =
      '/addCardPaymentMethodScreen';

  static const String addBankAccountInformationScreen =
      '/addBankAccountInformationScreen';

  static const String backgroundCheckScreen = '/backgroundCheckScreen';

  static const String verificationSelectionScreen =
      '/verificationSelectionScreen';
  static const String verificationCompletedScreen =
      '/verificationCompletedScreen';

  static const String providerTracking = '/providerTracking';
  static const String orderDetails = '/orderDetails';

  // referidos y employess ,settings
  static const String referralScreen = '/referralScreen';
  static const String employeeScreen = '/employeeScreen';
  static const String companyProfileScreen = '/companyProfileScreen';
  static const String twoFactorSetupScreen = '/twoFactorSetupScreen';
  static const String verificationScreen = '/verificationScreen';

  static const String provideraboutScreen = '/providerProfile';
  static const String providereditaboutScreen = '/editProfile';
  static const String previewScreen = '/preview';

// services

  static const String primierServiceScreen = '/primierServiceScreen';
  static const String seconServiceScreen = '/seconServiceScreen';
  static const String lastServiceScreen = '/lastServiceScreen';
// PAYMENT SETTING
  static const String paymentssettings = '/paymentssettings';
  static const String paymentssettingsadd_car = '/paymentssettingsadd_car';
  static const String paymentssettingsadd_bank = '/paymentssettingsadd_bank';
  static const String paymentssettingsedit_car = '/paymentssettingsedit_car';
  static const String paymentssettingsedit_bank = '/paymentssettingsedit_bank';
  //chats
  static const String customerChatScreen = '/customerChat';
  static const String supportChatScreen = '/supportChat';
  static const String chatListScreen = '/chatListScreen';

  static const String changePasswordScreen = '/changePasswordScreen';
  static const String mainScreen = '/mainScreen';
  static const String ClientmainScreen = '/clientmainScreen';
  static const String homeScreen = '/homeScreen';
  static const String bookingScreen = '/bookingScreen';
  static const String serviceScreen = '/serviceScreen';
  static const String updateServiceScreen = '/updateServiceScreen';
  static const String walletScreen = '/walletScreen';
  static const String registerProviderScreen = '/registerProviderScreen';
  static const String serviceDetailsScreen = '/serviceDetailsScreen';
  static const String addNewServiceScreen = '/addNewServiceScreen';
  static const String bookingDetailsScreen = '/bookingDetailsScreen';

  static const String bookingTrackingScreen = '/booking-tracking';

  static const String privacyPolicyScreen = '/privacyPolicyScreen';
  static const String termsConditionScreen = '/termsConditionScreen';
  static const String faqScreen = '/faqScreen';
  static const String contactUsScreen = '/contactUsScreen';
  static const String aboutUsScreen = '/aboutUsScreen';

  static const String profileScreen = '/profileScreen';
  static const String updateProfileScreen = '/updateProfileScreen';
  static const String providerProfileScreen = '/updateShopScreen';
  static const String scheduleScreen = '/scheduleScreen';
  static const String reviewScreen = '/reviewScreen';
  static const String singleReviewScreen = '/singleReviewScreen';
  static const String supportTicketScreen = '/supportTicketScreen';
  static const String supportInbox = '/supportInbox';
  static const String successPasswordScreen = '/successPasswordScreen';

  static const String senttingsScreen = '/senttingsScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String changepasswordScreen = '/changePasswordScreen';
  static const String configurationScreen = '/configurationScreen';
  static const String performanceScreen = '/performanceScreen';
  static const String reviewOnTasksScreen = '/reviewOnTasksScreen';

  static const String clientCategoryScreen = '/clientCategoryScreen';

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SplashScreen());

      case RouteNames.onBoardingScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const OnBoardingScreen());
      case RouteNames.authenticationScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AuthenticationScreen());

      case RouteNames.accountVerificationScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const AccountVerificationScreen());

      case RouteNames.forgotPasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ForgotPasswordScreen());
      case RouteNames.resetOptionSelectionScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const ResetOptionSelectionScreen());

      case RouteNames.verificationCodeScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const VerificationCodeScreen());

      case RouteNames.createCandidateScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const CreateCandidateScreen());

      case RouteNames.accountTypeSelectionScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const AccountTypeSelectionScreen());
      /* case RouteNames.providerTypeSelectionScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => ProviderTypeSelectionScreen());*/
      case RouteNames.providerSelectionEmployer:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const IndependentProviderSelectionScreen());
      case RouteNames.createAccountScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => CreateAccountPage1());

      case RouteNames.signUpBusinessAccountScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const BusinessAccountScreen());

      case RouteNames.clientRegistrationExistingScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => ClientRegistrationExistingScreen());

      case RouteNames.signUpWithBusinessCodeScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const SignUpWithBusinessCodeScreen());

      case RouteNames.passwordAccountpage:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const PasswordAccountpage());

      case RouteNames.addCardPaymentMethodScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => PaymentInformationScreen());

      case RouteNames.backgroundCheckScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => BackgroundCheckPage());

      case RouteNames.addBankAccountInformationScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AddBankAccountPage());
      case RouteNames.verificationSelectionScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const VerificationSelectionScreen());
      case RouteNames.verificationCompletedScreen:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const VerificationCompletedScreen());
      case RouteNames.homeScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const HomeScreen());
      case RouteNames.mainScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MainScreen());
      case RouteNames.ClientmainScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ClientMainScreen());
      case RouteNames.serviceDetailsScreen:
        final id = settings.arguments as String;
        return MaterialPageRoute(
            settings: settings, builder: (_) => ServiceDetailsScreen(id: id));
      case RouteNames.addNewServiceScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AddNewTaskScreen());

      case RouteNames.primierServiceScreen:
        // Asegúrate de recibir los argumentos correctamente como un Map
        final arguments = settings.arguments as Map<String, dynamic>;
        final ServiceModel service = arguments['service'] as ServiceModel;
        final List<Category> categories =
            arguments['categories'] as List<Category>;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PremierServiceScreen(
            selectedService: service,
            availableCategories: categories,
            taskId: '',
          ),
        );

      case RouteNames.customerChatScreen:
        // Recibe los argumentos como un Map<String, dynamic>
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;

        // Asegúrate de que las claves coincidan con las que pasas en la navegación
        final String chatRoomId = arguments['chatRoomId'] as String;
        final String customerId = arguments['customerId'] as String;
        final String providerId = arguments['providerId'] as String;
        final bool isFakeData = arguments['isFakeData'] as bool;
        final String orderId =
            arguments['orderId'] as String; // Incluye el orderId

        // Pasa los datos recibidos a la pantalla de chat
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CustomerChatScreen(
            chatRoomId: chatRoomId,
            customerId: customerId,
            providerId: providerId,
            isFakeData: isFakeData,
            orderId: orderId, // Pasa el orderId a la pantalla
          ),
        );

      case RouteNames.supportChatScreen:
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;

        // Extrae los datos de los argumentos
        final String chatRoomId = arguments['chatRoomId'] as String;
        final String userId = arguments['userId'] as String;

        // Pasa los datos a la pantalla de soporte técnico
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SupportChatScreen(
            chatRoomId: chatRoomId,
            userId: userId,
          ),
        );

      case RouteNames.chatListScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ChatListScreen());
      case RouteNames.seconServiceScreen:
        // Extract the arguments passed from the previous screen
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;

        // Extract the data from the arguments map
        final ServiceModel selectedService =
            arguments['selectedService'] as ServiceModel;
        final String selectedSize = arguments['selectedSize'] as String;
        final String hours = arguments['hours'] as String;
        final int quantity = arguments['quantity'] as int;

        // Pass the extracted arguments to the Service screen
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Service(
            selectedService: selectedService,
            selectedSize: selectedSize,
            hours: hours,
            quantity: quantity,
          ),
        );

      case RouteNames.lastServiceScreen:
        final args = settings.arguments
            as Map<String, dynamic>; // Cast the arguments to the expected type
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BookingStepScreen(),
        );

      case RouteNames.bookingDetailsScreen:
        final id = settings.arguments as String;
        return MaterialPageRoute(
            settings: settings, builder: (_) => BookingDetailsScreen(id: id));
      /*case RouteNames.bookingTrackingScreen: quite
        final id = settings.arguments as String;
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => BookingTrackingScreen(bookingId: id));*/
      case RouteNames.bookingScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ProviderOrdersScreen());

      case RouteNames.senttingsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SettingsScreen());
      case RouteNames.editProfileScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const EditProfileScreen());
      case RouteNames.changePasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ChangePasswordScreen());
      case RouteNames.configurationScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ConfigurationScreen());

      case RouteNames.performanceScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const PerformanceScreen());
      case RouteNames.reviewOnTasksScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ReviewOnTasksScreen());
      case RouteNames.clientCategoryScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ClientCategoryScreen());

      case RouteNames.orderDetails:
        final orderDetailsDto = settings.arguments as OrderDetailsDto;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderDetails(order: orderDetailsDto),
        );

      case RouteNames.providerTracking:
        final order = settings.arguments as OrderDetailsDto;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProviderTrackingScreen(order: order),
        );
      case RouteNames.referralScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ReferralScreen(),
        );
      case RouteNames.employeeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EmployeeScreen(),
        );
      case RouteNames.companyProfileScreen:
        final company =
            settings.arguments as String; // Recibe el modelo de la compañía
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompanyProfileScreen(
            companyId: company,
          ),
        );
      case RouteNames.twoFactorSetupScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TwoFactorSetupScreen(),
        );

      case RouteNames.verificationScreen:
        final metho = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerificationScreen(
            authMethod: metho,
          ),
        );
      case RouteNames.provideraboutScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final userId = args['userId'] as String;
        return MaterialPageRoute(builder: (_) => AboutMeScreen(userId: userId));

      case RouteNames.providereditaboutScreen:
        return MaterialPageRoute(builder: (_) => const EditAboutMeScreen());
      case RouteNames.previewScreen:
        return MaterialPageRoute(builder: (_) => const PreviewAboutMeScreen());

      case RouteNames.paymentssettings:
        return MaterialPageRoute(builder: (_) => const PaymentSettingsScreen());
      case RouteNames.paymentssettingsadd_car:
        return MaterialPageRoute(builder: (_) => const AddCardScreen());
      case RouteNames.paymentssettingsadd_bank:
        return MaterialPageRoute(builder: (_) => const AddBankAccountScreen());
      case RouteNames.paymentssettingsedit_car:
        final card = settings.arguments as CardModel;
        return MaterialPageRoute(
            builder: (_) => EditCardScreen(
                  card: card,
                ));
      case RouteNames.paymentssettingsedit_bank:
        final bank = settings.arguments as BankAccountModel;
        return MaterialPageRoute(
            builder: (_) => EditBankAccountScreen(
                  account: bank,
                ));

      case RouteNames.learningScreen:
        return MaterialPageRoute(builder: (_) => const LearningScreen());

      /*  
      case RouteNames.registerProviderScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const RegisterProviderScreen());

      case RouteNames.changePasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ChangePasswordScreen());

      // case RouteNames.registrationScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const RegistrationFormScreen());
      //
      // case RouteNames.createProviderScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const CreateProviderScreen());
      //
      

      case RouteNames.reviewScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ReviewScreen());

      case RouteNames.scheduleScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ScheduleScreen());

      // case RouteNames.singleReviewScreen:
      //   final id = settings.arguments as String;
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => SingleReviewScreen(id: id));
      //
  

      

      // case RouteNames.successPasswordScreen:
      //   return MaterialPageRoute(
      //       settings: settings,
      //       builder: (_) => const SuccessfulUpdatePasswordScreen());
      //
      // case RouteNames.forgotPasswordScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const ForgotPassword());
      // case RouteNames.verificationCodeScreen:
      //   final isRegister = settings.arguments as bool;
      //
      //   return MaterialPageRoute(
      //       settings: settings,
      //       builder: (_) => VerificationScreen(
      //             registerCode: isRegister,
      //           ));
      //
      // case RouteNames.updatePasswordScreen:
      //   final pin = settings.arguments as String;
      //   return MaterialPageRoute(
      //       settings: settings,
      //       builder: (_) => UpdatePasswordScreen(pinCode: pin));
      //

      case RouteNames.profileScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ProfileScreen());

      case RouteNames.updateProfileScreen:
        final user = settings.arguments as UserWithCountryResponse;
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => UpdateProfileScreen(user: user));
      //
      // case RouteNames.providerProfileScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const ProviderProfileScreen());
      //

      case RouteNames.privacyPolicyScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const PrivacyPolicyScreen());

      case RouteNames.termsConditionScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const TermsConditionScreen());

      case RouteNames.faqScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const FaqScreen());
      case RouteNames.contactUsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ContactUsScreen());

      case RouteNames.aboutUsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AboutUsScreen());

      
      
     
      case RouteNames.serviceScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ServiceScreen());
      case RouteNames.walletScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const WalletScreen());

      case RouteNames.updateServiceScreen:
        //final response = settings.arguments as ServiceDetailsResponse;
        return MaterialPageRoute(
            settings: settings, builder: (_) => const UpdateServiceScreen());

      // case RouteNames.supportTicketScreen:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => const SupportScreen(),
      //   );
      //
      // case RouteNames.supportInbox:
      //   final id = settings.arguments as String;
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => SupportInbox(ticketId: id),
      //   );
*/
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No Route Found ${settings.name}'),
            ),
          ),
        );
    }
  }
}
