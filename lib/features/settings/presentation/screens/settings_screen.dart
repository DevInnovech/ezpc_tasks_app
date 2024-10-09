import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    // esto debe ser sustituido por un valor dentro de los provedores si son clientes
    // y vicerversa uno para los clientes si son provedores o tiene mabs cuentas
    int esclient = 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        child: Column(
          children: [
            _buildProfileHeader(context),
            SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: _buildSettingsOptions(context, accountType),
              ),
            ),
            if (accountType == AccountType.client)
              esclient == 0
                  ? _buildActionButton(context, 'Become a Provider')
                  : _buildActionButton(context, 'Switch to Provider')
            else
              esclient == 0
                  ? _buildActionButton(context, 'Become a Client')
                  : _buildActionButton(context, 'Switch to Client'),
            _buildDeleteAccount(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: CustomImage(
              url: null,
              path: KImages.pp,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
            ),
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alam Cordero',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('alamcordero1230@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsOptions(BuildContext context, AccountType? accountType) {
    List<Widget> options = [
      _buildOption(
        context,
        Icons.person,
        'Edit Profile',
        ontap: () => Navigator.pushNamed(context, RouteNames.editProfileScreen),
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
      _buildOption(context, Icons.payment, 'Payment Settings'),
      _buildOption(context, Icons.share, 'Referrals'),
      _buildOption(context, Icons.history, 'View transaction history'),
      _buildOption(context, Icons.language, 'Language')
    ];

    if (accountType == AccountType.corporateProvider) {
      options.insert(4, _buildOption(context, Icons.group, 'Employees'));
    } else if (accountType == AccountType.employeeProvider) {
      options.insert(4, _buildOption(context, Icons.apartment, 'My Company'));
    }

    options.addAll([
      _buildOption(
        context,
        Icons.logout,
        'Logout',
        ontap: () => _showLogoutDialog(context),
      ),
      if (accountType == AccountType.client ||
          accountType == AccountType.independentProvider)
        _buildCopyReferral(context, '4897165120185'),
      if (accountType == AccountType.corporateProvider)
        _buildCopyReferral(context, 'BSC76823'),
    ]);

    return Column(
      children: options,
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
                labelText: 'Referral Number',
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referral code copied')),
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
          content: Text('Are you sure you want to log out?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add logout logic here
              },
              child: Text(
                'No',
                style: TextStyle(color: primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add logout logic here
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: Size(double.infinity, 40),
        ),
      ),
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'Delete Account',
          style: TextStyle(
            color: greyColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
