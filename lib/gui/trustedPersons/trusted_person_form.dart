/// 302FoundFrontend (2025) - Form widget to collect a trusted person's contact details.
///
/// Encapsulates validation and creation of a lightweight [User] instance which
/// is returned via the [onPersonAdded] callback when the form is submitted.
///
/// Example:
/// ```dart
/// TrustedPersonForm(onPersonAdded: (user) => trustService.createTrust(...))
/// ```
import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/logic/models/user.dart';

/// TrustedPersonForm collects basic data (name, phone, email) and validates it.
///
/// When the form is valid, calling [submitForm] builds a [User] object and
/// passes it to [onPersonAdded].
class TrustedPersonForm extends StatefulWidget {
  final Function(User) onPersonAdded;

  const TrustedPersonForm({super.key, required this.onPersonAdded});

  @override
  TrustedPersonFormState createState() => TrustedPersonFormState();
}

class TrustedPersonFormState extends State<TrustedPersonForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  /// Validate and submit the form; builds a [User] and calls [onPersonAdded].
  ///
  /// Example:
  /// ```dart
  /// submitForm();
  /// ```
  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final person = User(
        username: _nameController.text.trim(),
        fullname: _nameController.text.trim(),
        phonenumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );
      widget.onPersonAdded(person);
    }
  }

  /// Basic email validation used by the form field validator.
  ///
  /// @param value candidate email string
  /// @return error message when invalid, otherwise null
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte geben Sie eine E-Mail-Adresse ein.';
    }

    final email = value.trim();

    // Basic email validation using RegExp
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(email)) {
      return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
    }

    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name der Vertrauensperson',
                helperText: ' ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte geben Sie einen Namen ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefonnummer',
                helperText: ' ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte geben Sie eine Telefonnummer ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-Mail-Adresse',
                helperText: ' ',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
          ],
        ),
      ),
    );
  }
}
