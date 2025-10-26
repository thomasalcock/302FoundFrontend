/// 302FoundFrontend (2025) - Small helper widget to display and edit an attribute.
///
/// Renders a label + value and opens a dialog to edit the value. Uses a
/// callback [onChange] to propagate the new value to the parent (e.g. the
/// account screen which then calls UserService.updateUserById).
import 'package:flutter/material.dart';

/// A simple editable attribute row.
///
/// - [label]: visible name of the attribute (e.g. "Email").
/// - [value]: current value shown in the UI.
/// - [onChange]: called with the new value when the user saves the dialog.
///
/// Example:
/// ```dart
/// ModifiableAttribute(
///   label: 'Email',
///   value: user.email ?? 'Not set',
///   onChange: (v) => _updateUserData('email', v),
/// )
/// ```
class ModifiableAttribute extends StatefulWidget {
  const ModifiableAttribute({
    super.key,
    required this.label,
    required this.value,
    required this.onChange,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChange;

  @override
  ModifiableAttributeState createState() => ModifiableAttributeState();
}

class ModifiableAttributeState extends State<ModifiableAttribute> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.value),
            TextButton(
              onPressed: () {
                // Show an input dialog. The dialog stores the edited value in a
                // local variable and only calls onChange when the user confirms.
                showDialog(
                  context: context,
                  builder: (context) {
                    String newValue = widget.value;
                    return AlertDialog(
                      title: Text('${widget.label} ändern'),
                      content: TextField(
                        onChanged: (value) {
                          newValue = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Neue ${widget.label} eingeben',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Notify parent of the new value and close dialog.
                            widget.onChange(newValue);
                            Navigator.of(context).pop();
                          },
                          child: Text('speichern'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('ändern'),
            ),
          ],
        ),
      ],
    );
  }
}
