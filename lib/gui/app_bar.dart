import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Hessentag | $title'),
      actions: [
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
