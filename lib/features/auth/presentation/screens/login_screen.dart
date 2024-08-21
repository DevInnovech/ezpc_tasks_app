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
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  SharedPreferences? _preferences;
  String? email;
  String? password;
  bool isRemember = false;
  bool showPassword = false;

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
                  onPressed: () {
                    Utils.closeKeyBoard(context);
                    Navigator.pushNamedAndRemoveUntil(
                        context, RouteNames.mainScreen, (route) => false);
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
                borderSide: BorderSide(
                    color: Colors.transparent), // Sin borde inicialmente
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Colors.transparent), // Borde sin color por defecto
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: primaryColor, width: 2.0), // Borde azul al enfocarse
              ),
              suffixIcon: Icon(Icons.mail_outline,
                  color: Colors.grey), // Icono al final
              contentPadding: EdgeInsets.symmetric(
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
                borderSide: BorderSide(
                    color: Colors.transparent), // Sin borde inicialmente
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Colors.transparent), // Borde sin color por defecto
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
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
              contentPadding: EdgeInsets.symmetric(
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
