import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key, required this.title});
  final String title;

  @override
  AppBar build(BuildContext context) {
    return AppBar(title: Text('Hessentag - $title'));
  }
}
