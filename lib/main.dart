import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:threeotwo_found_frontend/trustedPersons/trusted_persons_list_view.dart';
import 'package:threeotwo_found_frontend/account/account_view.dart';
import 'services/location_service.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Start the app-level location manager so it collects/sends positions.
  final lm = LocationManager();
  lm.start();

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
      home: TrustedPersonsListView(),
      routes: {'/account': (context) => const AccountView()},
    );
  }
}
