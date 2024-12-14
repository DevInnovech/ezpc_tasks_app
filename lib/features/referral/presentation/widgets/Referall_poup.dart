import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralPopup extends StatelessWidget {
  final String referralCode;

  const ReferralPopup({super.key, required this.referralCode});

  final String titulo = 'Get 5 by helping your friends';
  final String subtitulo =
      'They get 5 off their first task and you get 5 when they complete it.';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // Controlar el ancho
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50), // Fondo azul oscuro
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.card_giftcard,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "https://ezpctasks.com/$referralCode",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: "https://ezpctasks.com/$referralCode",
                      ),
                    ).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard!'),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(100, 48), // Controlar tamaño mínimo
                  ),
                  child: const Text(
                    'Copy link',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    Share.share(
                      'Check out this app! Use my referral code: $referralCode to get started: https://ezpctasks.com/$referralCode',
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Referral program details: Share this link with your friends to earn rewards!',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info, color: Colors.white),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: '',
                      query: Uri.encodeFull(
                        'subject=Join and Earn Rewards!&body=Use my referral code: $referralCode to get started: https://ezpctasks.com/$referralCode',
                      ),
                    );
                    launchEmail(emailUri);
                  },
                  icon: const Icon(Icons.email, color: Colors.white),
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void launchEmail(Uri emailUri) async {
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      debugPrint('Could not launch email client');
    }
  }
}
