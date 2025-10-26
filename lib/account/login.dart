import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('LOGIN'),
            TextField(decoration: InputDecoration(labelText: 'Benutzername')),
            TextField(
              decoration: InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: null,
              child: Text('Anmelden'),
            ), // TODO: add login logic
          ],
        ),
      ),
    );
  }
}
