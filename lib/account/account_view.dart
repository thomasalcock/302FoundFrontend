import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/account/login.dart';
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
    debugPrint('AccountView: _loadCurrentUser start');
    try {
      final user = await UserService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        UserService.loggedInUser = user;
        _isLoading = false;
      });
      debugPrint('AccountView: _loadCurrentUser success for ${user.username}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load user: $e';
        _isLoading = false;
      });
      debugPrint('AccountView: _loadCurrentUser failed: $e');
    }
  }

  Future<void> _updateUserAttribute(String attribute, String newValue) async {
    if (_currentUser == null) return;

    try {
      User updatedUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        fullname: _currentUser!.fullname,
        phonenumber: attribute == 'phone'
            ? newValue
            : _currentUser!.phonenumber,
        email: attribute == 'email' ? newValue : _currentUser!.email,
        alias: _currentUser!.alias,
      );

      final user = await UserService.updateUserById(
        updatedUser,
        _currentUser!.id!,
      );

      setState(() {
        _currentUser = user;
        UserService.loggedInUser = user;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update user data: $e';
      });
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
                ],
              )
            : _currentUser == null
            ? Login()
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
                    onChange: (newValue) async {
                      await _updateUserAttribute('email', newValue);
                    },
                  ),
                  ModifiableAttribute(
                    label: 'Telefonnummer',
                    value: _currentUser!.phonenumber ?? 'Not set',
                    onChange: (newValue) async {
                      await _updateUserAttribute('phone', newValue);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentUser = null;
                        UserService.loggedInUser = null;
                      });
                    },
                    child: const Text('Ausloggen'),
                  ),
                ],
              ),
      ),
    );
  }
}
