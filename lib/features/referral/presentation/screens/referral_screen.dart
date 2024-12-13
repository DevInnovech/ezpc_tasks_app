import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referral_bonus_header.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referral_list.dart';
import 'package:flutter/material.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: ReferralList(),
      ),
    );
  }
}
