/// 302FoundFrontend (2025) - Account UI: view and edit current user attributes.
///
/// Contains the account screen which displays the current user's profile and
/// allows editing fields such as email and phone number via [ModifiableAttribute].
import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/gui/account/modifiable_attribute.dart';
import 'package:threeotwo_found_frontend/gui/app_bar.dart';
import 'package:threeotwo_found_frontend/logic/models/user.dart';
import 'package:threeotwo_found_frontend/logic/services/user_service.dart';

/// AccountView shows the current user's profile and editable attributes.
///
/// The view fetches the current user on init and renders [ModifiableAttribute]
/// widgets for editable fields.
///
/// Example:
/// ```dart
/// Navigator.pushNamed(context, '/account');
/// ```
class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  AccountViewState createState() => AccountViewState();
}

/// State backing for [AccountView].
///
/// Responsibilities:
/// - load current user via [UserService.getCurrentUser]
/// - update individual fields using [UserService.updateUserById]
class AccountViewState extends State<AccountView> {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  /// Fetch the current user and update state.
  ///
  /// Uses [UserService.getCurrentUser] and shows a loading indicator while the
  /// request is in-flight. On error an error message is stored in state.
  /// @return Future<void>
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
        // Preserve user-friendly message for UI; do not rethrow here.
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  /// Update a single user field and persist it via [UserService.updateUserById].
  ///
  /// @param field The logical field to update ('email' or 'phone').
  /// @param newValue The new string value to persist.
  /// @return Future<void>
  ///
  /// Example:
  /// ```dart
  /// _updateUserData('email', 'new@example.com');
  /// ```
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
        // Surface update failures to the user but keep state stable.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update $field: $e')));
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
                    child: const Text('Retry'),
                  ),
                ],
              )
            : _currentUser == null
            ? const Text('No user data available')
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
