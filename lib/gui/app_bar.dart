/// 302FoundFrontend (2025) - AppBar widget used across the app.
///
/// Provides a consistent application bar with optional debug actions.
/// Keep this file limited to UI concerns; navigation and debug helpers live here.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppBarWidget renders the top app bar and debug utilities.
///
/// The widget implements [PreferredSizeWidget] so it can be used directly as
/// the `appBar` property on [Scaffold].
///
/// Example:
/// ```dart
/// AppBarWidget(title: 'Home')
/// ```
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an app bar with the given [title].
  const AppBarWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Hessentag | $title'),
      actions: [
        // Debug-only button: shows the local SharedPreferences queue used by
        // the background location handler (bg_loc_queue). This is only visible
        // in debug builds to help development and troubleshooting.
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.bug_report, size: 36),
            tooltip: 'Show saved locations (debug)',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Saved locations (bg_loc_queue)'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: FutureBuilder<List<String>?>(
                      // Fetches the saved queue from SharedPreferences.
                      future: SharedPreferences.getInstance().then(
                        (prefs) => prefs.getStringList('bg_loc_queue'),
                      ),
                      builder: (ctx, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final list = snap.data ?? <String>[];
                        if (list.isEmpty) {
                          return const Text('No saved locations');
                        }
                        return Scrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              // Show newest first.
                              final item = list[list.length - 1 - index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(item),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          SharedPreferences.getInstance().then((prefs) {
                            // Delete the saved queue (development helper).
                            prefs.remove('bg_loc_queue');
                            Navigator.pop(c);
                          }),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );
            },
          ),
        // Account navigation button: avoids pushing route if already on /account.
        IconButton(
          icon: const Icon(Icons.account_circle, size: 40),
          onPressed: () {
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != '/account') {
              Navigator.pushNamed(context, '/account');
            }
          },
        ),
      ],
    );
  }

  /// Preferred size required by the Scaffold appBar contract.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
