import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_socialbutton.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/exit_dialog.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezpc_tasks_app/features/auth/data/auth_service.dart';

class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  ConsumerState<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  SharedPreferences? _preferences;
  final AuthService _authService = AuthService();
  String? email;
  String? password;
  bool isRemember = false;
  bool showPassword = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      email = _preferences?.getString('email');
      password = _preferences?.getString('password');
      setState(
          () {}); // Esto asegura que la UI se vuelva a construir con los valores cargados
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(accountTypeProvider);
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        showDialog(context: context, builder: (context) => const ExitDialog());
        return true;
      },
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        resizeToAvoidBottomInset: true,
        // appBar: AppBar(automaticallyImplyLeading: false),
        body: Container(
          height: size.height,
          width: size.width,
          padding: Utils.symmetric(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Utils.verticalSpace(15.0),
                CustomImage(
                  path: KImages.appLayer,
                  height: size.height * .25,
                  width: size.width * .5,
                  fit: BoxFit.contain,
                  url: null,
                ),
                Utils.verticalSpace(20.0),
                const CustomText(
                  text: "Welcome back you’ve\nbeen missed!",
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  height: 1.2,
                  textAlign: TextAlign.center,
                ),
                Utils.verticalSpace(24.0),
                _buildEmailForm(),
                Utils.verticalSpace(10.0),
                _buildPasswordForm(),
                Utils.verticalSpace(20.0),
                PrimaryButton(
                  text: 'Login',
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Ocultar el teclado
                          Utils.closeKeyBoard(context);

                          // Validar los campos
                          if (email == null ||
                              email!.isEmpty ||
                              password == null ||
                              password!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill in all fields')),
                            );
                            return;
                          }

                          try {
                            UserCredential? userCredential = await _authService
                                .signInWithEmailAndPassword(email!, password!);

                            if (userCredential != null) {
                              await _authService.savePreferences(
                                  email!, password!, isRemember);

                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user!.uid)
                                  .get();

                              if (userDoc.exists) {
                                final userStatus = userDoc.get('status');
                                final userRole = userDoc.get('accountType');

                                // Verificar estado del usuario
                                if (userStatus == 'Approved') {
                                  // Redirigir según el rol
                                  if (userRole == 'Client') {
                                    ref
                                        .read(accountTypeProvider.notifier)
                                        .selectAccountType(AccountType.client);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteNames.ClientmainScreen,
                                        (route) => false);
                                  } else if (userRole ==
                                      'Independent Provider') {
                                    ref
                                        .read(accountTypeProvider.notifier)
                                        .selectAccountType(
                                            AccountType.independentProvider);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteNames.mainScreen,
                                        (route) => false);
                                  } else if (userRole == 'Corporate Provider') {
                                    ref
                                        .read(accountTypeProvider.notifier)
                                        .selectAccountType(
                                            AccountType.corporateProvider);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteNames.mainScreen,
                                        (route) => false);
                                  } else if (userRole == 'Employee Provider') {
                                    ref
                                        .read(accountTypeProvider.notifier)
                                        .selectAccountType(
                                            AccountType.employeeProvider);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteNames.mainScreen,
                                        (route) => false);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'An error occurred. Unrecognized role.')),
                                    );
                                  }
                                  ///////////////////////////////////////////////
                                } else if (userStatus == 'Pending') {
                                  // Redirigir a pantalla de verificación
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      RouteNames.accountVerificationScreen,
                                      (route) => false);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Your account is not active. Contact support.')),
                                  );
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Incorrect email or password')),
                              );
                            }
                          } catch (e) {
                            print('Error during login: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'An error occurred during login')));
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                ),
                _buildRemember(),
                Utils.verticalSpace(12.0),
                _createNewAccount(context),
                Utils.verticalSpace(10.0),
                const CustomText(
                  text: "or continue with",
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  height: 1.2,
                  textAlign: TextAlign.center,
                ),
                Utils.verticalSpace(12.0),
                _loginextras(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return CustomForm(
      label: 'Email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
              filled: true,
              fillColor: TextFieldgraycolor, // Color de fondo
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                    color: Colors.transparent), // Sin borde inicialmente
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                    color: Colors.transparent), // Borde sin color por defecto
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                    color: primaryColor, width: 2.0), // Borde azul al enfocarse
              ),
              suffixIcon: const Icon(Icons.mail_outline,
                  color: Colors.grey), // Icono al final
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 20.0, horizontal: 12.0), // Espacio vertical
            ),
            initialValue: email,
            onChanged: (String value) {
              email = value;
            },
          ),
          if (email != null && email!.isEmpty)
            const ErrorText(text: 'Email cannot be empty'),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return CustomForm(
      label: 'Password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onChanged: (String value) {
              password = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter your Password',
              filled: true,
              fillColor: TextFieldgraycolor, // Color de fondo
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                    color: Colors.transparent), // Sin borde inicialmente
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                    color: Colors.transparent), // Borde sin color por defecto
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                    color: primaryColor,
                    width: 2.0), // Borde de color primario al enfocarse
              ),
              suffixIcon: IconButton(
                splashRadius: 16.0,
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: grayColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 20.0, horizontal: 12.0), // Espacio vertical
            ),
            initialValue: password,
            keyboardType: TextInputType.visiblePassword,
            obscureText: !showPassword,
          ),
          if (password != null && password!.isEmpty)
            const ErrorText(text: 'Password cannot be empty'),
        ],
      ),
    );
  }

  Widget _buildRemember() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: Utils.only(top: 0.0, left: 0),
              child: Theme(
                data: ThemeData(
                    checkboxTheme: CheckboxThemeData(
                        shape: RoundedRectangleBorder(
                  borderRadius: Utils.borderRadius(r: 3.0),
                ))),
                child: Checkbox(
                  onChanged: (bool? value) {
                    setState(() {
                      isRemember = value ?? false;
                    });
                  },
                  value: isRemember,
                  activeColor: primaryColor,
                ),
              ),
            ),
            const CustomText(
              text: 'Remember Me',
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: blackColor,
              height: 1.6,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
              context, RouteNames.resetOptionSelectionScreen),
          child: const CustomText(
            text: 'Forgot Password?',
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: primaryColor,
            height: 1.6,
            //decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _loginextras(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(
          imagePath: KImages.googleIcon,
          color: Colors.black,
          onTap: () {
            // Handle Google login
          },
        ),
        Utils.horizontalSpace(6.0),
        SocialButton(
          imagePath: KImages.facebookIcon,
          color: Colors.black,
          onTap: () {
            // Handle Facebook login
          },
        ),
        Utils.horizontalSpace(6.0),
        SocialButton(
          imagePath: KImages.applelogo, // Replace with your asset path
          color: Colors.black,

          onTap: () {
            // Handle Apple login
          },
        ),
        Utils.horizontalSpace(6.0),
        SocialButton(
          imagePath: KImages.editIcon, // Replace with your asset path
          color: Colors.black,

          onTap: () async {
            // Handle Apple login
            await approveAccountByEmail(email!);
          },
        ),
      ],
    );
  }

  Widget _createNewAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomText(
          text: "Don't have an account? ",
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: blackColor,
          height: 1.6,
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
              context, RouteNames.accountTypeSelectionScreen),
          child: const CustomText(
            text: 'Sign Up',
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// para aprovar cuentas y poder hacer pruebas
Future<void> approveAccountByEmail(String email) async {
  try {
    // Obtener referencia a Firestore
    final firestore = FirebaseFirestore.instance;

    // Buscar al usuario por correo electrónico
    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(
            1) // Limitar la búsqueda a un solo resultado para mayor eficiencia
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Obtener el ID del documento del usuario
      final doc = querySnapshot.docs.first;
      final docId = doc.id;

      // Verificar el estado actual antes de actualizar
      final currentStatus = doc.get('status');
      if (currentStatus == 'Approved') {
        print('Account with email $email is already approved.');
        return; // Salir si ya está aprobado
      }

      // Actualizar solo el estado del usuario a 'Approved'
      await firestore.collection('users').doc(docId).update({
        'status': 'Approved',
      });

      print('Account with email $email has been approved.');
    } else {
      print('No user found with the email $email.');
    }
  } catch (e) {
    print('Error approving account: $e');
  }
}
