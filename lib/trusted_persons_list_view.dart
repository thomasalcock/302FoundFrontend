import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/app_bar.dart';
import 'package:threeotwo_found_frontend/trusted_person_form.dart';
import 'package:threeotwo_found_frontend/trusted_person.dart';

class TrustedPersonsListView extends StatefulWidget {
  const TrustedPersonsListView({super.key});

  @override
  TrustedPersonsListViewState createState() => TrustedPersonsListViewState();
}

class TrustedPersonsListViewState extends State<TrustedPersonsListView> {
  final List<TrustedPerson> _trustedPersons = [];

  void _addTrustedPerson(TrustedPerson person) {
    setState(() {
      _trustedPersons.add(person);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(title: 'Notfallkontakte'),
      ),
      body: _trustedPersons.isEmpty
          ? const Center(
              child: Text(
                'Keine Vertrauenspersonen hinzugefügt.\nTippen Sie auf das + Symbol, um eine hinzuzufügen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _trustedPersons.length,
              itemBuilder: (context, index) {
                final person = _trustedPersons[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(person.name),
                  subtitle: Text('Telefonnummer: ${person.phoneNumber}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _trustedPersons.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Neue Vertrauensperson hinzufügen'),
                content: TrustedPersonForm(
                  onPersonAdded: (person) {
                    _addTrustedPerson(person);
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
