/// 302FoundFrontend (2025) - Trusted persons list UI.
///
/// Shows the user's saved emergency/trusted contacts and provides add/delete
/// functionality. The view uses a simple in-memory list in development; replace
/// with `TrustService` calls when integrating with backend APIs.
import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/gui/app_bar.dart';
import 'package:threeotwo_found_frontend/logic/models/user.dart';
import 'package:threeotwo_found_frontend/gui/trustedPersons/trusted_person_form.dart';

/// TrustedPersonsListView displays the list of saved contacts and actions.
///
/// Example:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => TrustedPersonsListView()));
/// ```
class TrustedPersonsListView extends StatefulWidget {
  const TrustedPersonsListView({super.key});

  @override
  TrustedPersonsListViewState createState() => TrustedPersonsListViewState();
}

/// State for [TrustedPersonsListView], holding the in-memory contacts list.
class TrustedPersonsListViewState extends State<TrustedPersonsListView> {
  final List<User> _trustedPersons = [];
  bool _isLoading = true;
  bool _isAdding = false;
  int _isDeleting = -1;

  @override
  void initState() {
    super.initState();
    _loadTrustedPersons();
  }

  /// Load initial contacts (development stub).
  ///
  /// Replace with a call to [TrustService.getTrustsByUserId] or similar when
  /// backend integration is available.
  Future<void> _loadTrustedPersons() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _trustedPersons.addAll([
        User(
          username: 'max_mustermann',
          fullname: 'Max Mustermann',
          phonenumber: '0123456789',
          email: 'max@mustermann.de',
        ),
        User(
          username: 'erika_mustermann',
          fullname: 'Erika Mustermann',
          phonenumber: '9876543210',
          email: 'erika@mustermann.de',
        ),
      ]);
      _isLoading = false;
    });
  }

  /// Add a new trusted person and update the list/UI.
  ///
  /// @param person The [User] instance created from the form.
  Future<void> _addTrustedPerson(User person) async {
    setState(() {
      _isAdding = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _trustedPersons.add(person);
      _isAdding = false;
    });
  }

  /// Delete the trusted person at [index].
  ///
  /// Shows a short loading state while the deletion is simulated.
  Future<void> _deleteTrustedPerson(int index) async {
    setState(() {
      _isDeleting = index;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _trustedPersons.removeAt(index);
      _isDeleting = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Notfallkontakte'),
      body: _trustedPersons.isEmpty
          ? Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'Keine Vertrauenspersonen hinzugefügt.\nTippen Sie auf das + Symbol, um eine hinzuzufügen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
            )
          : ListView.builder(
              itemCount: _isAdding
                  ? _trustedPersons.length + 1
                  : _trustedPersons.length,
              itemBuilder: (context, index) {
                if (_isAdding && index == _trustedPersons.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final person = _trustedPersons[index];
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(person.fullname),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Tel.: ${person.phonenumber}'),
                          Text('Mail: ${person.email}'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: _isDeleting == index
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteTrustedPerson(index);
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final GlobalKey<TrustedPersonFormState> formKey =
              GlobalKey<TrustedPersonFormState>();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Neue Vertrauensperson hinzufügen'),
                content: TrustedPersonForm(
                  key: formKey,
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
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState?.submitForm();
                    },
                    child: const Text('Hinzufügen'),
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
