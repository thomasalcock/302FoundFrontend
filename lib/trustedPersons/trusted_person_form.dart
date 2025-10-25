import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/trustedPersons/trusted_person.dart';

class TrustedPersonForm extends StatefulWidget {
  final Function(TrustedPerson) onPersonAdded;

  const TrustedPersonForm({super.key, required this.onPersonAdded});

  @override
  TrustedPersonFormState createState() => TrustedPersonFormState();
}

class TrustedPersonFormState extends State<TrustedPersonForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name der Vertrauensperson',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Telefonnummer'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty &&
                _phoneController.text.trim().isNotEmpty) {
              final person = TrustedPerson(
                name: _nameController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
              );
              widget.onPersonAdded(person);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bitte füllen Sie alle Felder aus.'),
                ),
              );
            }
          },
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }
}
