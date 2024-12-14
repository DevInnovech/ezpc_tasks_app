import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReferralDialog extends StatefulWidget {
  const ReferralDialog({Key? key}) : super(key: key);

  @override
  State<ReferralDialog> createState() => _ReferralDialogState();
}

class _ReferralDialogState extends State<ReferralDialog> {
  final TextEditingController _referralController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _isValidReferralCode(String code) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('referralCode', isEqualTo: code)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _saveReferralPartner(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update({'referralPartner': code});
  }

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Tienes un código de referido?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ingresa el código de la persona que te refirió, o selecciona "No tengo referido". '
            'Este diálogo no volverá a mostrarse una vez que ingreses un código válido o indiques que no tienes uno.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _referralController,
            decoration: const InputDecoration(
              labelText: 'Código de referido',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () async {
                  // Usuario no tiene referido
                  setState(() {
                    _isLoading = true;
                  });
                  await _saveReferralPartner('no_referral');
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: _isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text("No tengo referido"),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final code = _referralController.text.trim();
                  if (code.isNotEmpty) {
                    setState(() {
                      _isLoading = true;
                    });
                    final isValid = await _isValidReferralCode(code);
                    if (isValid) {
                      // Guardar el código de referido en Firestore como 'referralPartner'
                      await _saveReferralPartner(code);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "El código de referido ingresado no es válido."),
                      ));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Por favor, ingresa un código de referido."),
                    ));
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Confirmar"),
        ),
      ],
    );
  }
}
