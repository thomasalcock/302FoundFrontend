import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/app_bar.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  AccountViewState createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Account'),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ;
          },
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}
