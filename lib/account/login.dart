import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/gui/trustedPersons/trusted_persons_list_view.dart';
import 'package:threeotwo_found_frontend/logic/services/user_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onTextChanged);
    _passwordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onTextChanged);
    _passwordController.removeListener(_onTextChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      await UserService.login(username, password);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TrustedPersonsListView()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LOGIN',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Benutzername'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Passwort'),
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ||
                          _usernameController.text.isEmpty ||
                          _passwordController.text.isEmpty
                      ? null
                      : _attemptLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Anmelden'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
