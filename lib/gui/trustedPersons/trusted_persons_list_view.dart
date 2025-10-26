/// 302FoundFrontend (2025) - Trusted persons list UI.
///
/// Shows the user's saved emergency/trusted contacts and provides add/delete
/// functionality. The view uses service-backed operations but keeps helpful
/// development debug output and a lightweight fallback behavior during failures.
import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/gui/app_bar.dart';
import 'package:threeotwo_found_frontend/logic/models/user.dart';
import 'package:threeotwo_found_frontend/gui/trustedPersons/trusted_person_form.dart';
import 'package:threeotwo_found_frontend/logic/services/trust_service.dart';
import 'package:threeotwo_found_frontend/logic/services/user_service.dart';
import 'package:threeotwo_found_frontend/logic/models/trust.dart';

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

  /// Map trustee user id -> trust id for quick lookup when deleting.
  Map<int, int> _trustIdByTrusteeId = {};

  @override
  void initState() {
    super.initState();
    // Lifecycle debug to confirm initState runs and the loader is triggered.
    debugPrint('TrustedPersonsListView: initState called');
    _loadTrustedPersons();
  }

  /// Load initial contacts from backend. Falls back to a local stub on error.
  Future<void> _loadTrustedPersons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('TrustedPersonsListView: starting to load trusted persons');

      // Prefer fetching the current user via the service.
      final currentUser = await UserService.getCurrentUser();
      final currentUserId = currentUser.id;
      if (currentUserId == null) {
        throw Exception('Current user id is null');
      }

      // Load trusts and then fetch trustee users in parallel.
      final trusts = await TrustService.getTrustsByUserId(currentUserId);
      final trusteeIds = trusts.map((t) => t.trusteeId).toList();
      final users = await Future.wait(
        trusteeIds.map((id) => UserService.getUserById(id)),
      );

      if (!mounted) return;
      setState(() {
        _trustedPersons.clear();
        _trustedPersons.addAll(users);
        _trustIdByTrusteeId = {for (var t in trusts) t.trusteeId: t.id ?? 0};
      });

      debugPrint(
        'TrustedPersonsListView: loaded ${users.length} trusted persons',
      );
    } catch (e) {
      // If backend loading fails, log and surface a user snackbar, and fall
      // back to a small local stub so the UI remains usable during development.
      debugPrint('Failed to load trusted persons from backend: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Vertrauenspersonen: $e'),
          ),
        );
      }

      // Fallback dev stub to keep the UI functional.
      if (mounted) {
        setState(() {
          _trustedPersons.clear();
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
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Add a new trusted person and update the list/UI.
  ///
  /// @param person The [User] instance created from the form.
  Future<void> _addTrustedPerson(User person) async {
    setState(() {
      _isAdding = true;
    });

    try {
      final currentUser = await UserService.getCurrentUser();
      final currentUserId = currentUser.id;
      if (currentUserId == null) throw Exception('Current user id is null');

      // Ensure the trustee user exists (create or return existing).
      final createdUser = await UserService.createUser(person);

      // Create the Trust relationship.
      final trust = Trust(
        id: 0,
        userId: currentUserId,
        trusteeId: createdUser.id ?? 0,
      );
      final createdTrust = await TrustService.createTrust(trust);

      if (!mounted) return;
      setState(() {
        _trustedPersons.add(createdUser);
        _trustIdByTrusteeId[createdUser.id ?? 0] = createdTrust.id ?? 0;
      });
    } catch (e) {
      debugPrint('Failed to add trusted person: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Hinzufügen der Vertrauensperson: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  /// Delete the trusted person at [index].
  ///
  /// Shows a short loading state while the deletion is simulated.
  Future<void> _deleteTrustedPerson(int index) async {
    setState(() {
      _isDeleting = index;
    });

    try {
      final person = _trustedPersons[index];
      final trusteeId = person.id;
      if (trusteeId != null) {
        final trustId = _trustIdByTrusteeId[trusteeId];
        if (trustId != null && trustId != 0) {
          await TrustService.deleteTrustById(trustId);
        }
      }

      if (!mounted) return;
      setState(() {
        _trustedPersons.removeAt(index);
        if (trusteeId != null) _trustIdByTrusteeId.remove(trusteeId);
      });
    } catch (e) {
      debugPrint('Failed to delete trusted person: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Löschen der Vertrauensperson: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = -1;
        });
      }
    }
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
