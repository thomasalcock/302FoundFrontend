import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/trustedPersons/trusted_person.dart';

class TrustedPersonForm extends StatefulWidget {
  final Function(TrustedPerson) onPersonAdded;

  const TrustedPersonForm({super.key, required this.onPersonAdded});

  @override
  TrustedPersonFormState createState() => TrustedPersonFormState();
}

class TrustedPersonFormState extends State<TrustedPersonForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final person = TrustedPerson(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );
      widget.onPersonAdded(person);
    }
  }

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
                helperText: ' ', // Reserve space for error messages
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
                helperText: ' ', // Reserve space for error messages
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
                helperText: ' ', // Reserve space for error messages
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
