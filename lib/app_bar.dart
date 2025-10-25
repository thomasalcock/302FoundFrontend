import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, required this.title});
  final String title;

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text('Hessentag | $title'),
      actions: [
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
