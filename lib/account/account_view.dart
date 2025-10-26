import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/account/modifiable_attribute.dart';
import 'package:threeotwo_found_frontend/app_bar.dart';
import 'package:threeotwo_found_frontend/models/user.dart';
import 'package:threeotwo_found_frontend/services/user_service.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  AccountViewState createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = await UserService.getCurrentUser();

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData(String field, String newValue) async {
    if (_currentUser == null) return;

    try {
      User updatedUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        fullname: _currentUser!.fullname,
        phonenumber: field == 'phone' ? newValue : _currentUser!.phonenumber,
        email: field == 'email' ? newValue : _currentUser!.email,
        alias: _currentUser!.alias,
      );

      if (_currentUser!.id != null) {
        await UserService.updateUserById(updatedUser, _currentUser!.id!);
        setState(() {
          _currentUser = updatedUser;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren von $field: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Account'),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurrentUser,
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              )
            : _currentUser == null
            ? const Text('Keine Nutzerdaten verfügbar.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentUser!.fullname,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${_currentUser!.username}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ModifiableAttribute(
                    label: 'Email',
                    value: _currentUser!.email ?? 'Not set',
                    onChange: (newValue) {
                      _updateUserData('email', newValue);
                    },
                  ),
                  ModifiableAttribute(
                    label: 'Telefonnummer',
                    value: _currentUser!.phonenumber ?? 'Not set',
                    onChange: (newValue) {
                      _updateUserData('phone', newValue);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
