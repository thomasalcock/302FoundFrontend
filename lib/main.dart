import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:threeotwo_found_frontend/trustedPersons/trusted_persons_list_view.dart';
import 'package:threeotwo_found_frontend/account/account_view.dart';
import 'package:threeotwo_found_frontend/account/login.dart';
import 'package:threeotwo_found_frontend/services/user_service.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hessentag Fulda 2026',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: UserService.loggedInUser != null
          ? const TrustedPersonsListView()
          : const Login(),
      routes: {'/account': (context) => const AccountView()},
    );
  }
}
