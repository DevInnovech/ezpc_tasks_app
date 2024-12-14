import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/features/settings/models/company_models.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _profileImageUrl = '';
  int _roleSwitchCounter = 1;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        // Obtener documento del usuario
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (!userDoc.exists) {
          throw Exception('User document not found in Firestore.');
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        // Actualizar datos en el estado
        setState(() {
          _name = '${data['name'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          _email = data['email'] ?? '';
          _profileImageUrl = data['profileImageUrl'] ?? '';
        });

        // Inicializar el contador y sincronizar el currentRole con el rol principal
        final String role = data['role'] ?? '';
        final String secondaryRole = data['secondaryRole'] ?? '';
        String currentRole = data['currentRole'] ?? '';

        if (currentRole.isEmpty) {
          // Si no hay currentRole, sincronizarlo con el rol principal
          currentRole = role;
          await _firestore.collection('users').doc(currentUser.uid).update({
            'currentRole': currentRole,
          });
          debugPrint(
              'Primera vez iniciando sesión. currentRole sincronizado con role: $role');
        }

        // Inicializar el contador en 1 (rol principal)
        setState(() {
          _roleSwitchCounter = 1;
        });

        debugPrint('Rol inicial: $currentRole');
        debugPrint('Contador inicial: $_roleSwitchCounter');
      } catch (e, stackTrace) {
        debugPrint('Error al cargar los datos del usuario: $e\n$stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final accountType = ref.watch(accountTypeProvider);
        final accountTypeset = ref.read(accountTypeProvider.notifier);
        print(accountType);
        int esclient = 0;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildSettingsOptions(context, accountType),
                  ),
                ),
                if (accountType == AccountType.client)
                  _buildActionButton(
                      context, 'Provider', accountType, accountTypeset)
                else
                  _buildActionButton(
                      context, 'Client', accountType, accountTypeset),
                _buildDeleteAccount(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: _profileImageUrl.isNotEmpty
                ? Image.network(
                    _profileImageUrl,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Icon(
                          Icons.error); // Fallback in case of error
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                  )
                : const Image(
                    image: AssetImage(KImages.pp),
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _name.isEmpty ? 'Loading...' : _name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _email.isEmpty ? 'Loading...' : _email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsOptions(BuildContext context, AccountType? accountType) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Text("Error loading user data");
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final currentRole = userData['currentRole'] ?? userData['role'] ?? '';
        final referralCode = userData['referralCode'] ?? '';

        List<Widget> options = [
          _buildOption(
            context,
            Icons.person,
            'Edit Profile',
            ontap: () =>
                Navigator.pushNamed(context, RouteNames.editProfileScreen),
          ),
          _buildOption(
            context,
            Icons.lock,
            'Change password',
            ontap: () =>
                Navigator.pushNamed(context, RouteNames.changePasswordScreen),
          ),
          _buildOption(
            context,
            Icons.settings,
            'Configuration',
            ontap: () =>
                Navigator.pushNamed(context, RouteNames.configurationScreen),
          ),
          _buildOption(
            context,
            Icons.payment,
            'Payment Settings',
            ontap: () =>
                Navigator.pushNamed(context, RouteNames.paymentssettings),
          ),
          _buildOption(
            context,
            Icons.share,
            'Referrals',
            ontap: () =>
                Navigator.pushNamed(context, RouteNames.referralScreen),
          ),
          _buildOption(context, Icons.history, 'View transaction history'),
        ];

        if (accountType != AccountType.client &&
            accountType != AccountType.employeeProvider) {
          options.insert(
            1,
            _buildOption(
              context,
              Icons.group,
              'About me',
              ontap: () => Navigator.pushNamed(
                  context, RouteNames.providereditaboutScreen),
            ),
          );
        }

        if (accountType == AccountType.corporateProvider) {
          options.insert(
            4,
            _buildOption(
              context,
              Icons.group,
              'Employees',
              ontap: () =>
                  Navigator.pushNamed(context, RouteNames.employeeScreen),
            ),
          );
        } else if (accountType == AccountType.employeeProvider) {
          options.insert(
            4,
            _buildOption(
              context,
              Icons.apartment,
              'My Company',
              ontap: () => Navigator.pushNamed(
                context,
                RouteNames.companyProfileScreen,
                arguments: Company(
                  image: KImages.d01,
                  name: "Tech Solutions",
                  fin: "12-3456789",
                  email: "info@techsolutions.com",
                  phone: "+1 123 456 7890",
                  address: "Dominican Republic",
                  description:
                      "We provide cutting-edge software development and IT consultancy services to businesses worldwide.",
                ),
              ),
            ),
          );
        }

        options.addAll([
          _buildOption(
            context,
            Icons.logout,
            'Logout',
            ontap: () => _showLogoutDialog(context),
          ),
          if (accountType == AccountType.client ||
              accountType == AccountType.independentProvider &&
                  referralCode.isNotEmpty)
            _buildCopyReferral(context, referralCode),
          if (accountType == AccountType.corporateProvider &&
              referralCode.isNotEmpty)
            _buildCopyReferral(context, referralCode),
        ]);

        return Column(
          children: options,
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String text,
      {Function()? ontap}) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(text),
      onTap: ontap,
    );
  }

  Widget _buildCopyReferral(BuildContext context, String referralCode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: referralCode),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Referral Code',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Referral code copied')),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.authenticationScreen,
                  (route) => false,
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context,
      String actionText,
      String currentRole,
      String secondaryRole,
      AccountType? accountType,
      AccountTypeNotifier accountset) {
    // Determinar el nuevo rol (el rol secundario)
    final targetRole = secondaryRole;

    // Mostrar el cuadro de diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            'Are you sure you want to $actionText? You will be redirected to your $targetRole dashboard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _navigateToSwitchRole(context, accountType,
                    accountset); // Llamar al método actualizado
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToSwitchRole(BuildContext context1,
      AccountType? accountType, AccountTypeNotifier accountset) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User document not found");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final String role = userData['role'] ?? '';
      final String secondaryRole = userData['secondaryRole'] ?? '';

      if (role.isEmpty) {
        throw Exception("Role or Secondary Role is not defined in Firestore.");
      }

      // Definimos la variable `routeName`
      String? routeName;

      if (secondaryRole.isEmpty || secondaryRole == '') {
        // Si no hay `secondaryRole`, manejamos el flujo de "become"
        accountType == AccountType.client
            ? Navigator.pushNamed(
                context1,
                RouteNames.backgroundCheckScreen,
              )
            : _showConfirmationbecomeDialog(context1, userData, user.uid);
      } else {
        // Intercambiamos valores de `role` y `secondaryRole`
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'role': secondaryRole, 'secondaryRole': role});
        debugPrint(
            'Roles intercambiados: Nuevo role=$secondaryRole, Nuevo secondaryRole=$role');

        // Determinar la ruta basada en el nuevo rol principal
        switch (secondaryRole) {
          case 'Client':
            routeName = RouteNames.ClientmainScreen;
            accountset.selectAccountType(AccountType.client);
            break;
          case 'Independent Provider':
            routeName = RouteNames.mainScreen;
            accountset.selectAccountType(AccountType.independentProvider);
            break;
          default:
            //        routeName = RouteNames.defaultScreen; // Ruta por defecto
            break;
        }

        // Navegar al dashboard correspondiente y reiniciar el árbol
        if (routeName != null) {
          Navigator.pushNamedAndRemoveUntil(
              context1, routeName, (route) => false);
          ScaffoldMessenger.of(context1).showSnackBar(
            SnackBar(content: Text('Switched to $secondaryRole view.')),
          );
        } else {
          throw Exception("Route name could not be determined.");
        }
      }
    } catch (e) {
      debugPrint('Error switching role: $e');
      ScaffoldMessenger.of(context1).showSnackBar(
        const SnackBar(content: Text('Failed to switch role.')),
      );
    }
  }

  void _showConfirmationbecomeDialog(
      BuildContext context, Map<String, dynamic> userdatas, String userid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Deseas convertirte en cliente?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userid)
                    .update({
                  'role': userdatas['role'],
                  'secondaryRole': 'Client',
                });

                debugPrint(
                    'Roles intercambiados: Nuevo role=${userdatas['role']}, Nuevo secondaryRole=Client');
                setState(() {});
                Navigator.of(context).pop(); // Cierra el diálogo
                // Aquí puedes agregar lógica para manejar el "Sí"

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Bienvenido como cliente!')),
                );
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, String defaultButtonText,
      AccountType? accountType, AccountTypeNotifier accountset) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Text("Error loading role data");
        }
        var buttonText = '';
        final psecondaryrole =
            defaultButtonText == 'Client' ? "Provider" : "Client";
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String role = userData['role'] ?? '';
        final String secondaryRole = userData['secondaryRole'] ?? '';
        if (secondaryRole.isEmpty || secondaryRole == '') {
          buttonText = "Become to $psecondaryrole";
        } else {
          buttonText = "Switch to $secondaryRole";
        }

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            onPressed: () =>
                _navigateToSwitchRole(context, accountType, accountset),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _showDeleteAccountDialog(context),
        child: const Text(
          'Delete Account',
          style: TextStyle(
            color: greyColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Do you really want to delete your account? This action cannot be undone.',
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(80, 40),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  User? currentUser = _auth.currentUser;
                  if (currentUser != null) {
                    try {
                      await _firestore
                          .collection('users')
                          .doc(currentUser.uid)
                          .delete();
                      await currentUser.delete();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteNames.authenticationScreen,
                        (route) => false,
                      );
                    } catch (e) {
                      print('Error deleting account: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete account'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(80, 40),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
