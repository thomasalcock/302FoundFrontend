import 'package:flutter/material.dart';

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
